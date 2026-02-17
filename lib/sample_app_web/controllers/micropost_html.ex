defmodule SampleAppWeb.MicropostHTML do
  use SampleAppWeb, :html
  import SampleAppWeb.CustomComponents
  embed_templates "../templates/static_pages/*"
end
