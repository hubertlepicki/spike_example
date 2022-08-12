defmodule SpikeExampleWeb.Surface.SimpleFormComponent do
  use SpikeExampleWeb, :form_surface_component
  alias SpikeExampleWeb.Surface.FormComponents.Input
  import SpikeExampleWeb.Debug

  data(success, :boolean, default: false)

  def mount(socket) do
    form = SpikeExample.SimpleForm.new(%{})
    {:ok, socket |> assign(%{form: form, errors: Spike.errors(form)})}
  end

  def render(%{success: true} = assigns) do
    ~H"""
    <div>
      <p>Success!</p>
      <a href="#" phx-click="reset">Start over</a>

      <hr/>
      <.sources />

      <hr/>
      <.debug_assigns form={@form} errors={@errors} success={@success} />
    </div>
    """
  end

  def render(%{form: _, errors: _} = assigns) do
    ~F"""
    <div>
      <div class="float-right">* required fields</div>
      <Input type="text" label="First name:" field={:first_name} form={@form} errors={@errors} target={@myself} />
      <Input type="text" label="Last name:" field={:last_name} form={@form} errors={@errors} target={@myself} />
      <Input type="email" label="E-mail:" field={:email_address} form={@form} errors={@errors} target={@myself} />
      <Input type="password" label="Password:" field={:password} form={@form} errors={@errors} target={@myself} />
      <Input type="checkbox" label="Do you accept Terms & Conditions? *" field={:accepts_conditions} form={@form} errors={@errors} target={@myself} />

      <div class="clearfix" />
      <a class="button" href="#" phx-click="submit" phx-target={@myself}>Submit</a>
      <a class="float-right" href="#" phx-click="reset" phx-target={@myself}>Reset</a>

      <hr/>
      <.sources />

      <hr/>
      <.debug_assigns form={@form} errors={@errors} success={@success} />
    </div>
    """
  end

  def sources(assigns) do
    ~H"""
    See source of this:
    <a href="https://github.com/hubertlepicki/spike_example/blob/main/lib/spike_example/simple_form.ex" target="_blank">Spike form</a>
    and
    <a href="https://github.com/hubertlepicki/spike_example/blob/main/lib/spike_example_web/live/surface/simple_component_live.ex" target="_blank">LiveView</a>
    """
  end

  def handle_event("submit", _, socket) do
    if socket.assigns.errors == %{} do
      {:noreply, socket |> assign(:success, true)}
    else
      {:noreply, socket |> assign(:form, Spike.make_dirty(socket.assigns.form))}
    end
  end

  def handle_event("reset", _, socket) do
    form = SpikeExample.SimpleForm.new(%{})

    new_socket =
      socket
      |> assign(%{
        form: form,
        errors: Spike.errors(form),
        success: false
      })

    {:noreply, new_socket}
  end
end

defmodule SpikeExampleWeb.Surface.SimpleComponentLive do
  use SpikeExampleWeb, :surface_live_view

  alias SpikeExampleWeb.Surface.SimpleFormComponent

  def render(assigns) do
    ~F"""
    <a href="/" class="float-right">Back to all examples</a>
    <h2>Simple form, handled in LiveComponent:</h2>

    <SimpleFormComponent id="simple-form-component" />
    """
  end
end
