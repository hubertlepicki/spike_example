defmodule SpikeExample.SignupForm.AccountOwner do
  use Spike.Form do
    field(:full_name, :string)
    field(:email_address, :string)
    field(:password, :string)
  end

  validates(:full_name, presence: true)
  validates(:password, presence: true, length: [min: 8])

  validates(:email_address,
    presence: true,
    by: &__MODULE__.validate_email_address_not_used/2,
    format: [with: ~r/^[A-Za-z0-9\._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/, allow_blank: true]
  )

  def validate_email_address_not_used(nil, _), do: :ok

  def validate_email_address_not_used(email, account_owner) do
    [signup_form, :account_owner] = Spike.validation_context(account_owner)

    cond do
      Enum.any?(signup_form.coworkers, fn coworker -> coworker.email_address == email end) ->
        {:error, "is already used by a coworker"}

      true ->
        :ok
    end
  end
end

defmodule SpikeExample.SignupForm.Coworker do
  use Spike.Form do
    field(:full_name, :string)
    field(:email_address, :string)
  end

  validates(:full_name, presence: true)

  validates(:email_address,
    presence: true,
    by: &__MODULE__.validate_email_address_not_used/2,
    format: [with: ~r/^[A-Za-z0-9\._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/, allow_blank: true]
  )

  def validate_email_address_not_used(nil, _), do: :ok

  def validate_email_address_not_used(email, coworker) do
    [signup_form, :coworkers] = Spike.validation_context(coworker)

    cond do
      signup_form.account_owner && signup_form.account_owner.email_address == email ->
        {:error, "is already used by account owner"}

      Enum.any?(signup_form.coworkers, fn other_coworker ->
        other_coworker.ref != coworker.ref && other_coworker.email_address == email
      end) ->
        {:error, "is already used by other coworker"}

      true ->
        :ok
    end
  end
end

defmodule SpikeExample.SignupForm do
  use Spike.Form do
    field(:company_name, :string)
    field(:plan_id, :integer)
    field(:subdomain, :string)
    field(:note, :string)

    field(:available_plans, {:array, :map}, private: true)

    embeds_one(:account_owner, __MODULE__.AccountOwner)
    embeds_many(:coworkers, __MODULE__.Coworker)
  end

  validates(:company_name, presence: true)
  validates(:plan_id, presence: true, by: &__MODULE__.validate_plan_id/2)
  validates(:subdomain, presence: true)
  validates(:coworkers, by: &__MODULE__.validate_users_within_paln_limits/2)

  def validate_users_within_paln_limits(_coworkers, %{plan_id: nil} = _form), do: :ok

  def validate_users_within_paln_limits(coworkers, form) do
    plan = form.available_plans |> Enum.find(&(&1.id == form.plan_id))

    if plan && plan.max_users < length(coworkers) + 1 do
      {:error, "you can only have #{plan.max_users} users on \"#{plan.name}\" plan"}
    else
      :ok
    end
  end

  def validate_plan_id(nil, _form), do: :ok

  def validate_plan_id(value, form) do
    form.available_plans
    |> Enum.map(& &1.id)
    |> Enum.member?(value)
    |> if do
      :ok
    else
      {:error, "is not an available plan"}
    end
  end

  def after_update(_old_form, new_form, changed_fields) do
    if :company_name in changed_fields &&
         :subdomain not in Spike.dirty_fields(new_form)[new_form.ref] do
      %{new_form | subdomain: generate_subdomain(new_form)}
    else
      new_form
    end
  end

  defp generate_subdomain(form) do
    (form.company_name || "")
    |> String.trim()
    |> String.downcase()
    |> String.replace(~r/[_\s]/, "-")
    |> String.replace(~r/[^a-z0-9-]/, "")
  end
end
