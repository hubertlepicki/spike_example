defmodule SpikeExampleWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use SpikeExampleWeb, :controller
      use SpikeExampleWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def html do
    quote do
      use Phoenix.Component
      # Import convenience functions from controllers

      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML

      # Core UI components and translation
      use Gettext, backend: SpikeExampleWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: SpikeExampleWeb.Endpoint,
        router: SpikeExampleWeb.Router,
        statics: SpikeExampleWeb.static_paths()
    end
  end

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: SpikeExampleWeb.Layouts]

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {SpikeExampleWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def form_live_view do
    quote do
      use Phoenix.LiveView,
        layout: {SpikeExampleWeb.Layouts, :app}

      unquote(html_helpers())

      use Spike.LiveView
    end
  end

  def surface_live_view do
    quote do
      use Surface.LiveView,
        layout: {SpikeExampleWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def form_surface_live_view do
    quote do
      use Surface.LiveView,
        layout: {SpikeExampleWeb.Layouts, :app}

      unquote(html_helpers())

      use Spike.Surface
    end
  end

  def form_surface_component do
    quote do
      use Surface.LiveComponent

      unquote(html_helpers())

      use Spike.Surface
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def form_live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())

      use Spike.LiveView
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      use Gettext, backend: SpikeExampleWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
