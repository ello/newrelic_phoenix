<img src="http://d324imu86q1bqn.cloudfront.net/uploads/user/avatar/641/large_Ello.1000x1000.png" width="200px" height="200px" />

# NewrelicPhoenix

Yet another New Relic elixir library targeting Phoenix and Ecto.

Read "Rational" below for more on why.

## Installation

Add `newrelic_phoenix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:newrelic_phoenix, "~> 0.1.0"}]
end
```

## Basic Usage

And add to your config:

```elixir
config :newrelic_phoenix,
  application_name: {:system "APPLICATION_NAME"}
  license_key: {:system, "NEW_RELIC_LICENSE_KEY"}

config :my_app, MyApp.Endpoint,
  instrumenters: [NewRelicPhoenix.Endpoint]

config :my_app, MyApp.Repo,
  loggers: [{Ecto.LogEntry, :log, []}, NewRelicPhoenix.Ecto]
```

This will give request time with segments for database time and view rendering.

**NOTE: Any Ecto queries that happen outside the request process will not be
reported - including background preloads.**

To add additional custom segments in the process serving the request you can
use the `record_segment` macro, for example adding Redis segments to Redix
calls:

```elixir
defmodule MyApp.Redis do
  use Supervisor
  import NewRelicPhoenix, only: [measure_segment: 2]

  def command([operation | _args] = command) do
    measure_segment {:redis, operation} do
      Redix.command(worker_pid(), command)
    end
  end
end
```

## Rational - WHY another newrelic library!?!?

### Why NewRelic?

Ello has historically used NewRelic to monitor all of the various Rails
codebases that run Ello (Some of them are open source, check it out!). We have
been quite happy using it and would like to continue using it for both new and
replacement codebases written in Elixir.

### Why Not Library X, Y, or Z?

After evaluating the other solutions we were not happy with what they provided.

* APIs that required passing conns into Repo calls and using Plugs instead of the
built in intrumentation were offputting.
* Maintainers not responsive to either issues or pull requests.

Frankly we thought we could do better.

### Are there drawbacks?

Yes. The measuring code internally uses the Process storage to record the
transaction in process before sending to a seperate process for reporting.
Storing in the process dictionary works great for typical web requests, but it
breaks down when you have things happen in other threads. In particular any
ecto queries that happen outside the current thread, such as concurrent
preloads are not recorded.

### Is there a better solution?

Maybe, we would love feedback and would love to improve this while not
sacrificing ease of use.


## License
This project is released under the [MIT License](blob/master/LICENSE.txt)

## Code of Conduct
Ello was created by idealists who believe that the essential nature of all
human beings is to be kind, considerate, helpful, intelligent, responsible,
and respectful of others. To that end, we will be enforcing
[the Ello rules](https://ello.co/wtf/policies/rules/) within all of our open
source projects. If you don’t follow the rules, you risk being ignored, banned,
or reported for abuse.
