defmodule SpikeExample.SignupForm do
  use Spike.FormData do
    field(:company_name, :string)
    field(:plan_id, :integer)
    field(:subdomain, :string)

    field(:available_plans, {:array, :map}, private: true)

    embeds_one(:account_owner, __MODULE__.AccountOwner)
    embeds_many(:coworkers, __MODULE__.Coworker)
  end

  validates(:company_name, presence: true)
  validates(:plan_id, presence: true, by: &__MODULE__.validate_plan_id/2)
  validates(:subdomain, presence: true)

  def validate_plan_id(nil, _context), do: :ok

  def validate_plan_id(value, context) do
    context.available_plans
    |> Enum.map(& &1.id)
    |> Enum.member?(value)
    |> if do
      :ok
    else
      {:error, "is not an available plan"}
    end
  end

  def after_update(_old_form_data, new_form_data, changed_fields) do
    if :company_name in changed_fields && :subdomain not in new_form_data.__dirty_fields__ do
      %{new_form_data | subdomain: generate_subdomain(new_form_data)}
    else
      new_form_data
    end
  end

  defp generate_subdomain(form_data) do
    (form_data.company_name || "")
    |> String.trim()
    |> String.downcase()
    |> String.replace(~r/[_\s]/, "-")
    |> String.replace(~r/[^a-z0-9-]/, "")
  end
end
