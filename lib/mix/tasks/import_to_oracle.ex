defmodule Mix.Tasks.ImportToOracle do
  use Mix.Task
  alias NimbleCSV.RFC4180, as: CSV

  @shortdoc "Run import csv to oracle"
  def run(args) do
    [first | _] = args

    case first do
      "xd" ->
        import_xd()

      "lis" ->
        import_lis()
    end

    # |> Enum.to_list()
    # |> IO.inspect()
  end

  defp import_lis() do
    "./lis.csv"
    # |> Path.expand()
    |> File.stream!()
    |> CSV.parse_stream()
    |> Enum.map(fn row ->
      IO.puts(generate_lis_sql(row))
    end)
  end

  defp import_xd() do
    "./xd.csv"
    # |> Path.expand()
    |> File.stream!()
    |> CSV.parse_stream()
    |> Enum.map(fn row ->
      IO.puts(generate_xd_sql(row))
    end)
  end

  def generate_xd_sql([_lineno | lefo]) do
    fields = [
      "REPORTNO",
      "REPORTDATETIME",
      "REPORTDOCTOR",
      "AUDITDATETIME",
      "AUDITDOCTOR",
      "ELECTRICAXIS",
      "QRSD",
      "PR",
      "QT",
      "QTC",
      "SV1",
      "RV5",
      "RS",
      "HR",
      "DIAGNOSIS",
      "JCSJ",
      "YX"
    ]

    values =
      Enum.map(lefo, fn
        value when is_binary(value) and value != "" -> "'#{String.replace(value, "'", "''")}'"
        _ -> "NULL"
      end)

    "INSERT INTO XD (" <>
      Enum.join(fields, ", ") <> ") VALUES (" <> Enum.join(values, ", ") <> ");"
  end

  def generate_lis_sql([_lineno | lefo]) do
    fields = [
      "REPORTNO",
      "OBSERVATIONTYPECODE",
      "REPORTDATETIME",
      "REPORTDOCTOR",
      "SPECIMENRECEIVEDATETIME",
      "REQDOCTOR",
      "ANALYSISDATETIME",
      "INSPECTIONDOCTOR",
      "AUDITDATETIME",
      "LABNAME",
      "LABMEDICALDIRECTOR",
      "CODE",
      "CODEEN",
      "NAME",
      "VALUE",
      "UNITS",
      "RANGE",
      "REMARK",
      "STATUS",
      "EFFECTIVEDATE",
      "INSPECTIONITEMCODE",
      "INSPECTIONITEMNAME"
    ]

    values =
      Enum.map(lefo, fn
        value when is_binary(value) and value != "" -> "'#{String.replace(value, "'", "''")}'"
        _ -> "NULL"
      end)

    "INSERT INTO LIS (" <>
      Enum.join(fields, ", ") <> ") VALUES (" <> Enum.join(values, ", ") <> ");"
  end
end
