defmodule Habanero.Loader.Supervisor do
  # This will hold the supervisor for loaded plugin genservers

  def validate_plugin() do
    # validate that the module can spawn a genserver and respond as expected
  end

  def get_plugin_config() do
    # get the config for initializing plugins from the application
    # not sure yet what the configuration would look like, yaml?
    # for now probably just assume it's plain yaml files that are sitting in config/ or something
  end
end
