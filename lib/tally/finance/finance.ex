defmodule Tally.Finance do
  @moduledoc """
  The Finance context manages expenses, income, vendors, categories, and attachments.
  """

  import Ecto.Query, warn: false
  alias Tally.Repo
  alias Tally.Finance.{Category, Vendor, Expense, Income, Attachment}

  # ──────────────────── Categories ────────────────────

  def list_categories do
    Repo.all(from c in Category, order_by: [asc: c.kind, asc: c.name])
  end

  def list_expense_categories do
    Repo.all(from c in Category, where: c.kind == "expense", order_by: [asc: c.name])
  end

  def list_income_categories do
    Repo.all(from c in Category, where: c.kind == "income", order_by: [asc: c.name])
  end

  def get_category!(id), do: Repo.get!(Category, id)

  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = cat, attrs) do
    cat
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = cat), do: Repo.delete(cat)

  def change_category(%Category{} = cat, attrs \\ %{}) do
    Category.changeset(cat, attrs)
  end

  # ──────────────────── Vendors ────────────────────

  def list_vendors do
    Repo.all(from v in Vendor, order_by: [asc: v.name])
  end

  def get_vendor!(id), do: Repo.get!(Vendor, id)

  def create_vendor(attrs \\ %{}) do
    %Vendor{}
    |> Vendor.changeset(attrs)
    |> Repo.insert()
  end

  def update_vendor(%Vendor{} = vendor, attrs) do
    vendor
    |> Vendor.changeset(attrs)
    |> Repo.update()
  end

  def delete_vendor(%Vendor{} = vendor), do: Repo.delete(vendor)

  def change_vendor(%Vendor{} = vendor, attrs \\ %{}) do
    Vendor.changeset(vendor, attrs)
  end

  # ──────────────────── Expenses ────────────────────

  def list_expenses(filters \\ %{}) do
    Expense
    |> apply_txn_filters(filters)
    |> preload([:category, :vendor, :animal])
    |> order_by([e], desc: e.txn_date)
    |> Repo.all()
  end

  def list_expenses_for_animal(animal_id) do
    Expense
    |> where([e], e.animal_id == ^animal_id)
    |> preload([:category, :vendor])
    |> order_by([e], desc: e.txn_date)
    |> Repo.all()
  end

  def get_expense!(id) do
    Repo.get!(Expense, id)
    |> Repo.preload([:category, :vendor, :animal, :attachments])
  end

  def create_expense(attrs \\ %{}) do
    %Expense{}
    |> Expense.changeset(attrs)
    |> Repo.insert()
  end

  def update_expense(%Expense{} = expense, attrs) do
    expense
    |> Expense.changeset(attrs)
    |> Repo.update()
  end

  def delete_expense(%Expense{} = expense), do: Repo.delete(expense)

  def change_expense(%Expense{} = expense, attrs \\ %{}) do
    Expense.changeset(expense, attrs)
  end

  # ──────────────────── Incomes ────────────────────

  def list_incomes(filters \\ %{}) do
    Income
    |> apply_txn_filters(filters)
    |> preload([:category, :animal])
    |> order_by([i], desc: i.txn_date)
    |> Repo.all()
  end

  def list_incomes_for_animal(animal_id) do
    Income
    |> where([i], i.animal_id == ^animal_id)
    |> preload([:category])
    |> order_by([i], desc: i.txn_date)
    |> Repo.all()
  end

  def get_income!(id) do
    Repo.get!(Income, id)
    |> Repo.preload([:category, :animal, :attachments])
  end

  def create_income(attrs \\ %{}) do
    %Income{}
    |> Income.changeset(attrs)
    |> Repo.insert()
  end

  def update_income(%Income{} = income, attrs) do
    income
    |> Income.changeset(attrs)
    |> Repo.update()
  end

  def delete_income(%Income{} = income), do: Repo.delete(income)

  def change_income(%Income{} = income, attrs \\ %{}) do
    Income.changeset(income, attrs)
  end

  # ──────────────────── Attachments ────────────────────

  def list_unlinked_attachments do
    Attachment
    |> where([a], is_nil(a.expense_id) and is_nil(a.income_id))
    |> order_by([a], desc: a.inserted_at)
    |> Repo.all()
  end

  def get_attachment!(id), do: Repo.get!(Attachment, id)

  def create_attachment(attrs \\ %{}) do
    %Attachment{}
    |> Attachment.changeset(attrs)
    |> Repo.insert()
  end

  def update_attachment(%Attachment{} = att, attrs) do
    att
    |> Attachment.changeset(attrs)
    |> Repo.update()
  end

  def delete_attachment(%Attachment{} = att), do: Repo.delete(att)

  def change_attachment(%Attachment{} = att, attrs \\ %{}) do
    Attachment.changeset(att, attrs)
  end

  # ──────────────────── Summaries ────────────────────

  @doc """
  Returns YTD totals: total_income, total_expenses, net.
  """
  def ytd_summary(year \\ nil) do
    year = year || Date.utc_today().year
    start_date = Date.new!(year, 1, 1)
    end_date = Date.new!(year, 12, 31)

    total_income =
      Income
      |> where([i], i.txn_date >= ^start_date and i.txn_date <= ^end_date)
      |> select([i], sum(i.amount))
      |> Repo.one() || Decimal.new(0)

    total_expenses =
      Expense
      |> where([e], e.txn_date >= ^start_date and e.txn_date <= ^end_date)
      |> select([e], sum(e.amount))
      |> Repo.one() || Decimal.new(0)

    %{
      year: year,
      total_income: total_income,
      total_expenses: total_expenses,
      net: Decimal.sub(total_income, total_expenses)
    }
  end

  @doc """
  Returns per-animal finance rollup: total_expenses, total_income, net.
  """
  def animal_finance_summary(animal_id) do
    total_expenses =
      Expense
      |> where([e], e.animal_id == ^animal_id)
      |> select([e], sum(e.amount))
      |> Repo.one() || Decimal.new(0)

    total_income =
      Income
      |> where([i], i.animal_id == ^animal_id)
      |> select([i], sum(i.amount))
      |> Repo.one() || Decimal.new(0)

    %{
      total_expenses: total_expenses,
      total_income: total_income,
      net: Decimal.sub(total_income, total_expenses)
    }
  end

  defp apply_txn_filters(query, filters) do
    Enum.reduce(filters, query, fn
      {:year, year}, q when year != "" ->
        start_date = Date.new!(String.to_integer(year), 1, 1)
        end_date = Date.new!(String.to_integer(year), 12, 31)
        where(q, [t], t.txn_date >= ^start_date and t.txn_date <= ^end_date)
      {:category_id, id}, q when id != "" ->
        where(q, [t], t.category_id == ^String.to_integer(id))
      {:animal_id, id}, q when id != "" ->
        where(q, [t], t.animal_id == ^String.to_integer(id))
      _, q -> q
    end)
  end
end
