defmodule SpikeExample.SignupForm.AccountOwner do
  use Spike.FormData do
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
    [signup_form, :account_owner] = Spike.context(account_owner)

    cond do
      Enum.any?(signup_form.coworkers, fn coworker -> coworker.email_address == email end) ->
        {:error, "is already used by a coworker"}

      true ->
        :ok
    end
  end
end
