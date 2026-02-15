defmodule SampleAppWeb.EmailHTML do
  use SampleAppWeb, :html

  embed_templates "../templates/emails/*"
end
