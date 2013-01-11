require "hadoop-killer/version"
require 'yaml'
require 'open3'
require 'syslog'
require 'fileutils'
require 'pathname'
require 'optparse'
require 'timers'
require 'logger'

module Hadoop
module DevUitl
module ProcessKiller

class Watcher

  class NoSuchEventError < StandardError
  end

  def initialize(yaml)
    parse_yaml(yaml)
  end

  def parse_yaml(config_file)
    @config = load_yaml(config_file)
    @kill_config = @config['kill']
    @target = @kill_config['target'].to_s
    @max = @kill_config['max'].to_i
    @probability = @kill_config['probability'].to_i
    @interval = @kill_config['interval'].to_i

    if @probability == 0
      $stderr.puts "'probability' must be larger than 0."
      exit 1
    end

    @failure_cnt = 0
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
    #@logger.level = Logger::DEBUG

    @logger.debug("=== Option info ===")
    @logger.debug("target      :" + @target)
    @logger.debug("probability :" + @probability.to_s)
    @logger.debug("interval    :" + @interval.to_s)
    @logger.debug("max         :" + @max.to_s)
  end

  def load_yaml(file)
    config_path = File.join(File.dirname(__FILE__), '../../config')
    config_file = File.join(config_path, file)
    # puts config_file

    begin
      config = YAML.load_file(config_file)
    rescue => e
      $stderr.puts "Could not read configuration file:  #{e}"
      exit 1
    end
  end

  def exec_cmd(cmd, stdin=nil)
    o, e, s = Open3.capture3(cmd, :stdin_data => stdin)
    return [o, e, s]
  end

  def parse_result(output)
    ary = output.split("\n").map do |e|
      key, value = e.split(" ")
      [key.to_i, value.to_s]
    end
    Hash[ary]
  end

  def jps
    cmd = "jps"
    o, e, s = exec_cmd(cmd)
    # Transform results of jps command as hashmap.
    parse_result(o)
  end

  def happen_event?(name)
    f1 = @failure_cnt < @max
    if name.nil? || name.empty?
      @logger.debug("#{name} is nil or empty")
      return false
    end
    f2 = !name.scan(/#{@target}/).empty?
    f3 = rand(100) < @probability
    @logger.debug("cnt: #{f1.to_s}, scan: #{f2.to_s} rand #{f3.to_s}")
    f1 && f2 && f3
  end

  def kill(pid)
    begin
      Process.kill("SIGKILL", pid)
    rescue Errno::ESRCH, RangeError   => e
      @logger.debug("Pid #{pid} may exit, so ignore it.")
    rescue Errno::EPERM => e
      @logger.fatal("Doesn't kill the program because of permission.")
      exit 1
    end
  end

  def may_kill(processes)
    processes.each do |p|
      pid, name = p
      if (happen_event?(name))
        @logger.debug("try to kill #{name}(#{pid})")
        kill(pid)
        @failure_cnt += 1
        @logger.info("Killed pid #{pid} name #{name}")
      end
    end
  end

  def handle_event(event)
    case event
    when :kill
      if (@failure_cnt > @max)
        exit 0
      end

      processes = jps
      may_kill(processes)
    else
      throw NoSuchEventError.new
    end
  end

  def start
    timer = Timers.new
    every_five_seconds = timer.every(1) do
      handle_event(:kill)
    end

    loop do
      timer.wait
      sleep @interval
    end
    puts "Stopped."
  end
end

end # Killer
end # DevUtil
end # Hadoop

hdkiller = Hadoop::DevUitl::ProcessKiller::Watcher.new("policy.yml")
hdkiller.start()
