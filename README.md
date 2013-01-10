# Hadoop::Killer

Hadoop is a de fact standard analysis software. One sofisticated feature in Hadoop is fault torelance.
However, there is a one missing tool for hadoop development - fault injector, like ChaosMonkey.
`hadoop-killer` provides process-level fault injection by killing user-specified Java processes at user-specified probability.

## Requirement

* JDK 1.5 or later
* ruby 1.9.2

## Installation

    $ gem install hadoop-killer

## Usage

Edit config/policy.yml:

    kill:
     target : "YarnChild" # target daemon name
     max: 3		# max count of killing.
     probability: 20    # kill daemons at 20% of the time
     interval: 1	# each 1 seconds.

Launch `hadoop-killer`:

    bin/hdkiller

## TODO

1. Log-based process killing - if specified lines appears specified log, kill the container.
2. Cluster support - current version only supports local process.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
