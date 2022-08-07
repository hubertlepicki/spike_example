defmodule SpikeExample.SignupForm.Coworker do
  use Spike.FormData do
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
    [signup_form, :coworkers] = Spike.context(coworker)

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
