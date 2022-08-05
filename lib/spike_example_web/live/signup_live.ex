defmodule SpikeExampleWeb.SignupLive do
  use SpikeExampleWeb, :form_live_view
  import Spike.LiveView.{FormField, Errors}

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

    <label for="company_name">Company name:</label>
    <.form_field key={:company_name} form_data={@form_data}>
      <input id="company_name" name="value" type="text" value={@form_data.company_name} />
    </.form_field>

    <.errors let={field_errors} key={:company_name} form_data={@form_data} errors={@errors}>
      <span class="error">
        <%= field_errors |> Enum.map(fn {_k, v} -> v end) |> Enum.join(", ") %>
      </span>
    </.errors>

    <label for="subdomain">Your subdomain:</label>
    <.form_field key={:subdomain} form_data={@form_data}>
      <input id="subdomain" name="value" type="text" value={@form_data.subdomain} />
    </.form_field>

    <.errors let={field_errors} key={:subdomain} form_data={@form_data} errors={@errors}>
      <span class="error">
        <%= field_errors |> Enum.map(fn {_k, v} -> v end) |> Enum.join(", ") %>
      </span>
    </.errors>

    <label for="plan_id">Choose your plan:</label>
    <.form_field key={:plan_id} form_data={@form_data}>
      <select id="plan_id" name="value">
        <option value="" selected={@form_data.plan_id == nil}>Please select...</option>
        <%= for plan <- @form_data.available_plans do %>
          <option value={plan.id} selected={@form_data.plan_id == plan.id}><%= plan.name %></option>
        <% end %>
      </select>
    </.form_field>

    <.errors let={field_errors} key={:plan_id} form_data={@form_data} errors={@errors}>
      <span class="error">
        <%= field_errors |> Enum.map(fn {_k, v} -> v end) |> Enum.join(", ") %>
      </span>
    </.errors>

    <label for="account_owner_full_name">Your name:</label>
    <.form_field key={:full_name} form_data={@form_data.account_owner}>
      <input id="account_owner_full_name" name="value" type="text" value={@form_data.account_owner.full_name} />
    </.form_field>

    <.errors let={field_errors} key={:full_name} form_data={@form_data.account_owner} errors={@errors}>
      <span class="error">
        <%= field_errors |> Enum.map(fn {_k, v} -> v end) |> Enum.join(", ") %>
      </span>
    </.errors>

    <label for="account_owner_email">Your e-mail:</label>
    <.form_field key={:email_address} form_data={@form_data.account_owner}>
      <input id="account_owner_email_address" name="value" type="text" value={@form_data.account_owner.email_address} />
    </.form_field>

    <.errors let={field_errors} key={:email_address} form_data={@form_data.account_owner} errors={@errors}>
      <span class="error">
        <%= field_errors |> Enum.map(fn {_k, v} -> v end) |> Enum.join(", ") %>
      </span>
    </.errors>


    <%= if @form_data.coworkers |> length() > 0 do %>
      <h3>
        Yor co-workers
      </h3>
    <% end %>

    <%= for coworker <- @form_data.coworkers do %>
      <a class="float-right" href="#" phx-click="remove_coworker" phx-value-ref={coworker.ref}>x</a>

      <label for={"coworker_#{coworker.ref}_full_name"}>Coworker name:</label>
      <.form_field key={:full_name} form_data={coworker}>
        <input id={"coworker_#{coworker.ref}_full_name"} name="value" type="text" value={coworker.full_name} />
      </.form_field>

      <.errors let={field_errors} key={:full_name} form_data={coworker} errors={@errors}>
        <span class="error">
          <%= field_errors |> Enum.map(fn {_k, v} -> v end) |> Enum.join(", ") %>
        </span>
      </.errors>

      <label for={"coworker_#{coworker.ref}_email_address"}>Coworker e-mail:</label>
      <.form_field key={:email_address} form_data={coworker}>
        <input id={"coworker_#{coworker.ref}_email_address"} name="value" type="text" value={coworker.email_address} />
      </.form_field>

      <.errors let={field_errors} key={:email_address} form_data={coworker} errors={@errors}>
        <span class="error">
          <%= field_errors |> Enum.map(fn {_k, v} -> v end) |> Enum.join(", ") %>
        </span>
      </.errors>
    <% end %>


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
      %{id: 1, name: "Starter", price: 0},
      %{id: 2, name: "Growth", price: 1},
      %{id: 3, name: "Enterprise", price: 9000}
    ]
  end
end
