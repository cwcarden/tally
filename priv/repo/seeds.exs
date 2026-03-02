# Script for populating the database.
# Run with: mix run priv/repo/seeds.exs

alias Tally.Repo
alias Tally.Accounts
alias Tally.Livestock.{Breed, EventType}
alias Tally.Finance.Category

# ──────────────────── Admin User ────────────────────
admin_email = System.get_env("SEED_EMAIL", "admin@gimelranch.com")
admin_password = System.get_env("SEED_PASSWORD", "password")

case Accounts.register_user(%{email: admin_email, password: admin_password}) do
  {:ok, user} ->
    IO.puts("Created admin user: #{user.email}")
  {:error, changeset} ->
    case changeset.errors do
      [{:email, {"has already been taken", _}} | _] ->
        IO.puts("Admin user already exists: #{admin_email}")
      errors ->
        IO.inspect(errors, label: "User creation error")
    end
end

# ──────────────────── Breeds ────────────────────
breeds = [
  %{name: "Quarter Horse", species: "horse", description: "American breed, versatile ranch horse"},
  %{name: "Paint", species: "horse", description: "Colorful coat patterns, American breed"},
  %{name: "Appaloosa", species: "horse", description: "Spotted coat, Nez Perce heritage"},
  %{name: "Thoroughbred", species: "horse", description: "Racing and performance breed"},
  %{name: "Arabian", species: "horse", description: "Ancient breed, endurance and refinement"},
  %{name: "Angus", species: "cattle", description: "Black beef cattle, excellent marbling"},
  %{name: "Hereford", species: "cattle", description: "Red and white beef breed"},
  %{name: "Longhorn", species: "cattle", description: "Texas Longhorn, heritage breed"},
  %{name: "Charolais", species: "cattle", description: "French white/cream beef breed"},
  %{name: "Brangus", species: "cattle", description: "Brahman × Angus cross"},
  %{name: "Border Collie", species: "dog", description: "Intelligent herding dog"},
  %{name: "Australian Shepherd", species: "dog", description: "Versatile herding and ranch dog"},
  %{name: "Blue Heeler", species: "dog", description: "Australian Cattle Dog, tough herder"},
  %{name: "Catahoula", species: "dog", description: "Louisiana hog hunting and herding dog"},
]

Enum.each(breeds, fn attrs ->
  case Repo.get_by(Breed, name: attrs.name) do
    nil -> Repo.insert!(struct(Breed, attrs))
    _ -> :ok
  end
end)
IO.puts("Seeded #{length(breeds)} breeds")

# ──────────────────── Event Types ────────────────────
event_types = [
  %{name: "Vaccination", description: "Immunization shot or booster"},
  %{name: "Vet Visit", description: "Examination by veterinarian"},
  %{name: "Farrier", description: "Hoof trimming and shoeing"},
  %{name: "Worming / Deworming", description: "Parasite treatment"},
  %{name: "Weaning", description: "Separated from mother"},
  %{name: "Branding", description: "Brand applied"},
  %{name: "Castration", description: "Neutering procedure"},
  %{name: "Preg Check", description: "Pregnancy examination"},
  %{name: "Breeding", description: "Bred to sire"},
  %{name: "Birth", description: "Foal/calf born"},
  %{name: "Weight / BCS", description: "Body weight or condition score recorded"},
  %{name: "Injury / Treatment", description: "Wound care or illness treatment"},
  %{name: "Sold", description: "Animal sold or transferred"},
  %{name: "Purchase", description: "Animal purchased or acquired"},
  %{name: "Show / Exhibition", description: "Entered in show or exhibition"},
  %{name: "Training", description: "Training session or milestone"},
  %{name: "General Note", description: "General observation or note"},
]

Enum.each(event_types, fn attrs ->
  case Repo.get_by(EventType, name: attrs.name) do
    nil -> Repo.insert!(struct(EventType, attrs))
    _ -> :ok
  end
end)
IO.puts("Seeded #{length(event_types)} event types")

# ──────────────────── Finance Categories ────────────────────
categories = [
  # Expense categories
  %{name: "Feed & Hay", kind: "expense", report_form: "none"},
  %{name: "Veterinary", kind: "expense", report_form: "none"},
  %{name: "Farrier", kind: "expense", report_form: "none"},
  %{name: "Medications & Supplies", kind: "expense", report_form: "none"},
  %{name: "Equipment", kind: "expense", report_form: "none"},
  %{name: "Equipment Repair", kind: "expense", report_form: "none"},
  %{name: "Fuel", kind: "expense", report_form: "none"},
  %{name: "Labor", kind: "expense", report_form: "nec"},
  %{name: "Land / Lease", kind: "expense", report_form: "none"},
  %{name: "Fencing & Infrastructure", kind: "expense", report_form: "none"},
  %{name: "Insurance", kind: "expense", report_form: "none"},
  %{name: "Show Fees", kind: "expense", report_form: "none"},
  %{name: "Registration & Breed Fees", kind: "expense", report_form: "none"},
  %{name: "Transportation", kind: "expense", report_form: "none"},
  %{name: "Utilities", kind: "expense", report_form: "none"},
  %{name: "Professional Services", kind: "expense", report_form: "nec"},
  %{name: "Miscellaneous", kind: "expense", report_form: "none"},
  # Income categories
  %{name: "Livestock Sales", kind: "income", report_form: "none"},
  %{name: "Stud Fees", kind: "income", report_form: "none"},
  %{name: "Boarding", kind: "income", report_form: "none"},
  %{name: "Show Winnings / Premiums", kind: "income", report_form: "none"},
  %{name: "Hay / Crop Sales", kind: "income", report_form: "none"},
  %{name: "Government Program Payments", kind: "income", report_form: "misc10"},
  %{name: "Insurance Proceeds", kind: "income", report_form: "none"},
  %{name: "Other Income", kind: "income", report_form: "none"},
]

Enum.each(categories, fn attrs ->
  case Repo.get_by(Category, name: attrs.name) do
    nil -> Repo.insert!(struct(Category, attrs))
    _ -> :ok
  end
end)
IO.puts("Seeded #{length(categories)} categories")

IO.puts("\nSeeding complete!")
IO.puts("Login: #{admin_email} / #{System.get_env("SEED_PASSWORD", "TallyRanch2024!")}")
