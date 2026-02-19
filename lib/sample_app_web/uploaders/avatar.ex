defmodule SampleApp.Avatar do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  # Include ecto support (requires package waffle_ecto installed):
  # use Waffle.Ecto.Definition

  @versions [:original]
  @max_file_size 5_242_880

  # To add a thumbnail version:
  # @versions [:original, :thumb]

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # Whitelist file extensions:
  # def validate({file, _}) do
  #   file_extension = file.file_name |> Path.extname() |> String.downcase()
  #
  #   case Enum.member?(~w(.jpg .jpeg .gif .png), file_extension) do
  #     true -> :ok
  #     false -> {:error, "invalid file type"}
  #   end
  # end

  # Define a thumbnail transformation:
  # def transform(:thumb, _) do
  #   {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
  # end

  # Override the persisted filenames:
  # def filename(version, _) do
  #   version
  # end

  # Override the storage directory:
  # def storage_dir(version, {file, scope}) do
  #   "uploads/user/avatars/#{scope.id}"
  # end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: MIME.from_path(file.file_name)]
  # end

  def validate({file, _}) do
    extension = file.file_name |> Path.extname() |> String.downcase()
    size = file_size(file)

    cond do
      size > @max_file_size ->
        false

      extension == ".jpg" && is_jpg?(file) ->
        true

      extension == ".jpeg" && is_jpg?(file) ->
        true

      extension == ".png" && is_png?(file) ->
        true

      true ->
        false
    end
  end

  @doc """
  JPG magic bytes: 0xffd8
  """
  def is_jpg?(%Waffle.File{} = file) do
    with {:ok, file_content} <- :file.open(file.path, [:read, :binary]),
         {:ok, <<255, 216>>} <- :file.read(file_content, 2) do
      true
    else
      _error ->
        false
    end
  end

  @doc """
  PNG magic bytes: 0x89504e470d0a1a0a
  """
  def is_png?(%Waffle.File{} = file) do
    with {:ok, file_content} <- :file.open(file.path, [:read, :binary]),
         {:ok, <<137, 80, 78, 71, 13, 10, 26, 10>>} <-
           :file.read(file_content, 8) do
      true
    else
      _error ->
        false
    end
  end

  def file_size(%Waffle.File{} = file) do
    File.stat!(file.path) |> Map.get(:size)
  end

  def storage_dir(_version, {_file, _scope}) do
    "uploads/user/avatars/"
  end
end
