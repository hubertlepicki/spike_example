defmodule SpikeExample.SignupForm do
  use Spike.FormData do
    field(:company_name, :string)
    field(:plan_id, :integer)

    field(:available_plans, {:array, :map}, private: true)
  end

  validates(:company_name, presence: true)
end
