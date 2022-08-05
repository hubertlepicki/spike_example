defmodule SpikeExample.SignupForm.AccountOwner do
  use Spike.FormData do
    field(:full_name, :string)
    field(:email_address, :string)
  end

  validates(:full_name, presence: true)
  validates(:email_address, presence: true)
end
