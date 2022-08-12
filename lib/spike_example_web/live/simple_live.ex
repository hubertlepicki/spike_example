defmodule SpikeExampleWeb.SimpleLive do
  use SpikeExampleWeb, :form_live_view
  import SpikeExampleWeb.FormComponents
  import SpikeExampleWeb.Debug

  def mount(_, _, socket) do
    form = SpikeExample.SimpleForm.new(%{})
    {:ok, socket |> assign(%{form: form, errors: Spike.errors(form), success: false})}
  end

  def render(%{success: true} = assigns) do
    ~H"""
    <a href="/" class="float-right">Back to all examples</a>
    <h2>Simple form:</h2>

    <p>Success!</p>
    <a href="#" phx-click="reset">Start over</a>

    <hr/>
    <.sources />

    <hr/>
    <.debug_assigns form={@form} errors={@errors} success={@success} />
    """
  end

  def render(%{form: _, errors: _} = assigns) do
    ~H"""
    <a href="/" class="float-right">Back to all examples</a>
    <h2>Simple form:</h2>

    <div class="float-right">* required fields</div>
    <.input_component type="text" label="First name:" field={:first_name} form={@form} errors={@errors} />
    <.input_component type="text" label="Last name:" field={:last_name} form={@form} errors={@errors} />
    <.input_component type="email" label="E-mail:" field={:email_address} form={@form} errors={@errors} />
    <.input_component type="password" label="Password:" field={:password} form={@form} errors={@errors} />
    <.input_component type="checkbox" label="Do you accept Terms & Conditions? *" field={:accepts_conditions} form={@form} errors={@errors} />

    <div class="clearfix" />
    <a class="button" href="#" phx-click="submit">Submit</a>
    <a class="float-right" href="#" phx-click="reset">Reset</a>

    <hr/>
    <.sources />

    <hr/>
    <.debug_assigns form={@form} errors={@errors} success={@success} />
    """
  end

  def sources(assigns) do
    ~H"""
    See source of this:
    <a href="https://github.com/hubertlepicki/spike_example/blob/main/lib/spike_example/simple_form.ex" target="_blank">Spike form</a>
    and
    <a href="https://github.com/hubertlepicki/spike_example/blob/main/lib/spike_example_web/live/simple_live.ex" target="_blank">LiveView</a>
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
