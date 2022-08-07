defmodule SpikeExampleWeb.SignupLive do
  use SpikeExampleWeb, :form_live_view
  import SpikeExampleWeb.FormComponents

  def mount(_params, _, socket) do
    form_data = init_form_data()

    {:ok,
     socket
     |> assign(%{
       success: false,
       form_data: form_data,
       errors: Spike.errors(form_data)
     })}
  end

  def render(%{success: true} = assigns) do
    ~H"""
    <h2>Example signup form:</h2>

    <p>Signup successful!</p>
    <a href="#" phx-click="reset">Start over</a>
    """
  end

  def render(assigns) do
    ~H"""
    <h2>Example signup form:</h2>

    <div class="float-right">* required fields</div>
    <.input_component type="text" label="Company name:" key={:company_name} form_data={@form_data} errors={@errors} />
    <.input_component type="text" label="Subdomain:" key={:subdomain} form_data={@form_data} errors={@errors} />
    <.input_component type="select" label="Choose your plan:" key={:plan_id} form_data={@form_data} errors={@errors} options={plan_options(@form_data)} />
    <.input_component type="text" label="Your name:" key={:full_name} form_data={@form_data.account_owner} errors={@errors} />
    <.input_component type="text" label="Your email:" key={:email_address} form_data={@form_data.account_owner} errors={@errors} />
    <.input_component type="password" label="Your password:" key={:password} form_data={@form_data.account_owner} errors={@errors} />

    <.input_component type="textarea" label="How did you hear about us?" key={:note} form_data={@form_data} errors={@errors} />

    <br/>

    <%= if @form_data.coworkers |> length() > 0 do %>
      <h3>
        Your co-workers
      </h3>
    <% end %>

    <%= for coworker <- @form_data.coworkers do %>
      <a class="float-right" href="#" phx-click="remove_coworker" phx-value-ref={coworker.ref}>x</a>
      <.input_component type="text" label="Coworker name:" key={:full_name} form_data={coworker} errors={@errors} />
      <.input_component type="text" label="Coworker e-mail:" key={:email_address} form_data={coworker} errors={@errors} />
    <% end %>

    <.errors_component form_data={@form_data} key={:coworkers} errors={@errors} />

    <div class="clearfix" />
    <a class="float-right" href="#" phx-click="reset">Reset</a>
    <a class="button" href="#" phx-click="submit">Submit</a>
    <a class="button" href="#" phx-click="add_coworker">+ Add coworker</a>

    <hr/>

    <h4>Debug info</h4>
    Form data:
    <pre>
      <%= inspect @form_data, pretty: true %>
    </pre>

    Errors:
    <pre>
      <%= inspect @errors, pretty: true %>
    </pre>

    Success:
    <pre>
      <%= inspect @success, pretty: true %>
    </pre>

    """
  end

  def handle_event("submit", _, socket) do
    if socket.assigns.errors == %{} do
      {:noreply, socket |> assign(:success, true)}
    else
      {:noreply, socket |> assign(:form_data, Spike.make_dirty(socket.assigns.form_data))}
    end
  end

  def handle_event("reset", _, socket) do
    form_data = init_form_data()

    new_socket =
      socket
      |> assign(%{
        form_data: form_data,
        errors: Spike.errors(form_data),
        success: false
      })

    {:noreply, new_socket}
  end

  def handle_event("add_coworker", _, %{assigns: %{form_data: form_data}} = socket) do
    form_data = form_data |> Spike.append(form_data.ref, :coworkers, %{})
    errors = Spike.errors(form_data)
    {:noreply, socket |> assign(%{form_data: form_data, errors: errors})}
  end

  def handle_event(
        "remove_coworker",
        %{"ref" => ref},
        %{assigns: %{form_data: form_data}} = socket
      ) do
    form_data = form_data |> Spike.delete(ref)
    errors = Spike.errors(form_data)
    {:noreply, socket |> assign(%{form_data: form_data, errors: errors})}
  end

  defp init_form_data do
    SpikeExample.SignupForm.new(
      %{
        available_plans: find_plans(),
        account_owner: %{}
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

  defp plan_options(form_data) do
    [{nil, "Please select..."}] ++
      Enum.map(form_data.available_plans, fn plan ->
        {plan.id, "#{plan.name} (#{plan.price} USD / month)"}
      end)
  end
end
