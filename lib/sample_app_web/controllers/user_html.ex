defmodule SampleAppWeb.UserHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  import SampleAppWeb.CustomComponents

  use SampleAppWeb, :html

  embed_templates "../templates/user_pages/*"
end
