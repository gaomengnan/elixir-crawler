defmodule MyCrawler do
  use HTTPoison.Base

  alias MyCrawler.{Repo, Douban}
  import Ecto.Query, warn: false

  # alias Douban

  @moduledoc """
  Documentation for `MyCrawler`.
  """

  defp create_or_update(attrs) do
    movie_id = attrs[:movie_id]

    Repo.transaction(fn ->
      case Repo.get_by(Douban, movie_id: movie_id) do
        nil ->
          %Douban{}
          |> Douban.changeset(attrs)
          |> Repo.insert()

        douban ->
          douban
          |> Douban.changeset(attrs)
          |> Repo.update()
      end
    end)
  end

  @doc """
  Hello world.

  ## Examples

      iex> MyCrawler.hello()
      :world

  """
  def hello do
    :world
  end

  @doc """
  Fetch a URL.
  ## Examples
      iex> MyCrawler.fetch("http://example.com")
  """
  def fetch(url) do
    case get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp extract_number(url) do
    case Regex.run(~r/subject\/(\d+)/, url) do
      [_, number] -> number
      _ -> nil
    end
  end

  defp fetch_per_page(url) do
    case fetch(url) do
      {:ok, body} ->
        parse_html_document(body)
        # IO.inspect(resp, label: url)
        |> Enum.map(&save_data/1)

      {:error, reason} ->
        IO.puts("Failed to fetch page: #{reason}")
    end
  end

  defp save_data(data) do
    # IO.inspect(data)
    douban = %{
      movie_id: data[:movie_id],
      title: data[:title],
      url: data[:href],
      rank: data[:rank],
      score: data[:rate],
      comment_count: data[:comment_num],
      cover: data[:cover],
      desc: data[:base_comment]
    }

    case create_or_update(douban) do
      {:ok, struct} ->
        # IO.puts("Insert data: #{inspect(struct)}")
        struct

      {:error, changeset} ->
        IO.puts("Failed to insert data: #{inspect(changeset.errors)}")
        # nil
    end

    # changeset = Douban.changeset(douban)
    #
    # # IO.inspect(douban)
    # case Repo.insert(changeset) do
    #   {:ok, struct} ->
    #     IO.puts("Insert data: #{inspect(struct)}")
    #
    #   {:error, changeset} ->
    #     IO.puts("Failed to insert data: #{inspect(changeset.errors)}")
    # end
  end

  # MyCrawler.Repo.insert(MyCrawler.Repo.changeset(%MyCrawler.Repo{}, data)

  @doc """
  Parse a response body.
  """
  def parse_html_document(html) do
    {:ok, document} = Floki.parse_document(html)

    document
    |> Floki.find(".grid_view li")
    |> Enum.map(&parse_content_list/1)
  end

  # defp convert_quoted_number_to_integer(text) do
  #   String.trim(text, "\"")
  # end

  defp parse_content_list(element) do
    # 排名
    rank =
      element
      |> Floki.find(".pic em")
      |> List.first()
      |> Floki.text()
      # |> convert_quoted_number_to_integer()
      |> String.to_integer()

    # IO.inspect(rank)

    # 封面
    cover =
      element
      |> Floki.find(".pic a img")
      |> Floki.attribute("src")
      |> List.first()

    # 链接
    href =
      element
      |> Floki.find(".pic a")
      |> List.first()
      |> Floki.attribute("href")
      |> List.first()

    # 标题
    title =
      element
      |> Floki.find(".title, .other")
      |> Enum.map(&Floki.text/1)
      |> Enum.map(&String.replace(&1, ~r/&nbsp;/, " "))
      |> Enum.map(&String.trim/1)
      |> Enum.join("")

    # 描述
    desc =
      element
      |> Floki.find(".bd p")
      |> Floki.text()

    # 打分
    rate =
      element
      |> Floki.find(".star .rating_num")
      |> Floki.text()
      # |> convert_quoted_number_to_integer()
      |> String.to_float()

    # 评论人数
    comment_num =
      element
      |> Floki.find(".star span")
      |> List.last()
      |> Floki.text()
      |> extract_numbers
      # |> convert_quoted_number_to_integer()
      |> String.to_integer()

    # 最佳评论
    best_comment =
      element
      |> Floki.find(".quote .inq")
      |> Floki.text()

    # IO.inspect(%{
    #   rank: rank,
    #   cover: cover,
    #   href: href,
    #   title: title,
    #   desc: desc,
    #   rate: rate,
    #   comment_num: comment_num,
    #   base_comment: best_comment
    # })

    movie_id =
      href
      |> extract_number()
      |> String.to_integer()

    %{
      movie_id: movie_id,
      rank: rank,
      cover: cover,
      href: href,
      title: title,
      desc: desc,
      rate: rate,
      comment_num: comment_num,
      base_comment: best_comment
    }
  end

  defp extract_numbers(text) do
    case Regex.run(~r/\d+/, text) do
      [number] -> number
      _ -> ""
    end
  end

  defp fetch_pages(body) do
    {:ok, document} = Floki.parse_document(body)

    total =
      document
      |> Floki.find(".paginator .count")
      |> List.first()
      |> Floki.text()
      |> extract_numbers()
      |> String.to_integer()

    per_page = 25
    total_pages = div(total + per_page - 1, per_page)

    urls =
      for page <- 1..total_pages do
        IO.puts("Fetching page: #{page}")
        "https://movie.douban.com/top250?start=#{(page - 1) * 25}"
      end

    urls
    |> Enum.map(&Task.async(fn -> fetch_per_page(&1) end))
    |> Enum.flat_map(&Task.await(&1, 5000))

    # |> Enum.map(fn item ->  end)

    # |> Enum.sort_by(& &1["rank"])

    # |> Enum.each(fn item -> IO.inspect(item) end)

    # |> Enum.map(&Task.async(fn -> fetch(&1) end))
    #   |> Enum.map(&Task.await(&1, 5000))
    # IO.inspect(urls)
  end

  def run(url) do
    case fetch(url) do
      {:ok, body} ->
        fetch_pages(body)
        |> Enum.map(fn item ->
          case item do
            {:ok, data} -> data
            {:error, changeset} -> changeset.errors
          end
        end)

      # IO.inspect(resp)

      # resp = parse_html_document(body)
      # IO.puts("Page title: #{resp}")

      {:error, reason} ->
        IO.puts("Failed to fetch page: #{reason}")
    end
  end
end
