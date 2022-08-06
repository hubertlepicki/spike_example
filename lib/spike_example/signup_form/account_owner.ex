defmodule SpikeExample.SignupForm.AccountOwner do
  use Spike.FormData do
    field(:full_name, :string)
    field(:email_address, :string)
  end

  validates(:full_name, presence: true)
  validates(:email_address, presence: true)

  validates(:email_address, presence: true, by: &__MODULE__.validate_email_address_not_used/2)

  def validate_email_address_not_used(email, account_owner) do
    [signup_form, :account_owner] = Spike.context(account_owner)

    cond do
      Enum.any?(signup_form.coworkers, fn coworker -> coworker.email_address == email end) ->
        {:error, "is already used by a coworker"}

      true ->
        :ok
    end
  end
end
