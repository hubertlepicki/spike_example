defmodule SpikeExampleWeb.Debug do
  use SpikeExampleWeb, :component

  import Spike.LiveView.Components

  def debug_assigns(%{form: _, errors: _, success: _} = assigns) do
    ~H"""
    <h3>Debug info</h3>

    @form:
    <pre>
      <%= inspect @form, pretty: true %>
    </pre>

    @errors:
    <pre>
      <%= inspect @errors, pretty: true %>
    </pre>

    @success
    <pre>
      <%= inspect @success, pretty: true %>
    </pre>
    """
  end
end
