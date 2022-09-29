defmodule SpikeExampleWeb.SignupLive do
  use SpikeExampleWeb, :form_live_view
  import SpikeExampleWeb.FormComponents
  import SpikeExampleWeb.Debug

  def mount(_params, _, socket) do
    form = init_form()

    {:ok,
     socket
     |> assign(%{
       success: false,
       form: form,
       errors: Spike.errors(form)
     })}
  end

  def render(%{success: true} = assigns) do
    ~H"""
    <a href="/" class="float-right">Back to all examples</a>
    <h2>Example signup form:</h2>

    <p>Signup successful!</p>
    <a href="#" phx-click="reset">Start over</a>

    <hr/>
    <.sources />

    <hr/>
    <.debug_assigns form={@form} errors={@errors} success={@success} />
    """
  end

  def render(assigns) do
    ~H"""
    <a href="/" class="float-right">Back to all examples</a>
    <h2>Example signup form:</h2>

    <div class="float-right">* required fields</div>
    <.input_component type="text" label="Company name:" field={:company_name} form={@form} errors={@errors} />
    <.input_component type="text" label="Subdomain:" field={:subdomain} form={@form} errors={@errors} />
    <.input_component type="select" label="Choose your plan:" field={:plan_id} form={@form} errors={@errors} options={plan_options(@form)} />
    <.input_component type="multi_select" label="Your business category:" field={:category_ids} form={@form} errors={@errors} options={category_options()} />
    <.input_component type="text" label="Your name:" field={:full_name} form={@form.account_owner} errors={@errors} />
    <.input_component type="text" label="Your email:" field={:email_address} form={@form.account_owner} errors={@errors} />
    <.input_component type="password" label="Your password:" field={:password} form={@form.account_owner} errors={@errors} />

    <.input_component type="textarea" label="How did you hear about us?" field={:note} form={@form} errors={@errors} />

    <br/>

    <%= if @form.coworkers |> length() > 0 do %>
      <h3>
        Your co-workers
      </h3>
    <% end %>

    <%= for coworker <- @form.coworkers do %>
      <a class="float-right" href="#" phx-click="remove_coworker" phx-value-ref={coworker.ref}>x</a>
      <.input_component type="text" label="Coworker name:" field={:full_name} form={coworker} errors={@errors} />
      <.input_component type="text" label="Coworker e-mail:" field={:email_address} form={coworker} errors={@errors} />
    <% end %>

    <.errors_component form={@form} field={:coworkers} errors={@errors} />

    <div class="clearfix" />
    <a class="float-right" href="#" phx-click="reset">Reset</a>
    <a class="button" href="#" phx-click="submit">Submit</a>
    <a class="button" href="#" phx-click="add_coworker">+ Add coworker</a>

    <hr/>
    <.sources />

    <hr/>
    <.debug_assigns form={@form} errors={@errors} success={@success} />
    """
  end

  def sources(assigns) do
    ~H"""
    See source of this:
    <a href="https://github.com/hubertlepicki/spike_example/blob/main/lib/spike_example/signup_form.ex" target="_blank">Spike form</a>
    and
    <a href="https://github.com/hubertlepicki/spike_example/blob/main/lib/spike_example_web/live/signup_live.ex" target="_blank">LiveView</a>
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
    form = init_form()

    new_socket =
      socket
      |> assign(%{
        form: form,
        errors: Spike.errors(form),
        success: false
      })

    {:noreply, new_socket}
  end

  def handle_event("add_coworker", _, %{assigns: %{form: form}} = socket) do
    form = form |> Spike.append(form.ref, :coworkers, %{})
    errors = Spike.errors(form)
    {:noreply, socket |> assign(%{form: form, errors: errors})}
  end

  def handle_event(
        "remove_coworker",
        %{"ref" => ref},
        %{assigns: %{form: form}} = socket
      ) do
    form = form |> Spike.delete(ref)
    errors = Spike.errors(form)
    {:noreply, socket |> assign(%{form: form, errors: errors})}
  end

  defp init_form do
    SpikeExample.SignupForm.new(
      %{
        available_plans: find_plans(),
        account_owner: %{},
        coworkers: []
      },
      cast_private: true
    )
  end

  defp find_plans() do
    [
      %{id: 1, name: "Starter", price: 0, max_users: 1},
      %{id: 2, name: "Growth", price: 1, max_users: 5},
      %{id: 3, name: "Enterprise", price: 9000, max_users: :infinity}
    ]
  end

  defp plan_options(form) do
    [{nil, "Please select..."}] ++
      Enum.map(form.available_plans, fn plan ->
        {plan.id, "#{plan.name} (#{plan.price} USD / month)"}
      end)
  end

  defp category_options() do
    [
      {1, "Finance"},
      {2, "Retail"},
      {3, "Software"},
      {4, "Agriculture"},
      {5, "Military"},
      {6, "Education"}
    ]
  end
end
