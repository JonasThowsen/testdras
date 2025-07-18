defmodule DrasMvpWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use DrasMvpWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    # Add defensive check for current_scope and user
    logged_in? = assigns[:current_scope] && assigns.current_scope[:user]
    assigns = assign(assigns, :logged_in?, logged_in?)

    ~H"""
    <div class="min-h-screen bg-gray-50">
      <!-- Navigation Header -->
      <nav class="bg-white shadow border-b border-gray-200">
        <div class="max-w-7xl mx-auto px-4">
          <div class="flex justify-between items-center h-16">
            <!-- Logo & Main Title -->
            <div class="flex items-center">
              <.link navigate="/" class="flex items-center space-x-2 hover:opacity-80">
                <div class="w-8 h-8 bg-blue-600 rounded flex items-center justify-center">
                  <.icon name="hero-academic-cap" class="w-5 h-5 text-white" />
                </div>
                <span class="text-xl font-semibold text-gray-900">DRAS</span>
              </.link>
            </div>
            
    <!-- Navigation Links -->
            <div class="flex items-center space-x-6">
              <%= if @logged_in? do %>
                <.link
                  navigate="/"
                  class="text-gray-700 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium transition-colors"
                >
                  Dashboard
                </.link>
                <.link
                  navigate="/csv-import"
                  class="text-gray-700 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium transition-colors"
                >
                  CSV Import
                </.link>
                <.link
                  navigate="/study-programs"
                  class="text-gray-700 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium transition-colors"
                >
                  Study Programs
                </.link>
                <.link
                  navigate="/courses"
                  class="text-gray-700 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium transition-colors"
                >
                  Courses
                </.link>
                <.link
                  navigate="/users"
                  class="text-gray-700 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium transition-colors"
                >
                  Users
                </.link>
              <% end %>
              
    <!-- Authentication Section -->
              <div class="flex items-center space-x-2 border-l border-gray-300 pl-6">
                <%= if @logged_in? do %>
                  <!-- Logged in user controls -->
                  <div class="flex items-center space-x-3">
                    <span class="text-sm text-gray-600">
                      Welcome,
                      <span class="font-medium text-gray-900">
                        <%= if @current_scope && @current_scope.user do %>
                          {@current_scope.user.email}
                        <% else %>
                          User
                        <% end %>
                      </span>
                    </span>
                    <.link
                      navigate="/users/settings"
                      class="text-gray-600 hover:text-gray-900 text-sm font-medium"
                    >
                      Settings
                    </.link>
                    <.link
                      href="/users/log-out"
                      method="delete"
                      class="bg-red-600 text-white px-3 py-2 rounded-md text-sm font-medium hover:bg-red-700 transition-colors"
                    >
                      Log Out
                    </.link>
                  </div>
                <% else %>
                  <!-- Not logged in controls -->
                  <div class="flex items-center space-x-2">
                    <.link
                      navigate="/users/log-in"
                      class="text-gray-700 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium transition-colors"
                    >
                      Log In
                    </.link>
                    <.link
                      navigate="/users/register"
                      class="bg-blue-600 text-white px-3 py-2 rounded-md text-sm font-medium hover:bg-blue-700 transition-colors"
                    >
                      Register
                    </.link>
                  </div>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      </nav>
      
    <!-- Main Content -->
      <main>
        {render_slot(@inner_block)}
      </main>
    </div>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title="We can't find the internet"
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title="Something went wrong!"
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        Attempting to reconnect
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "system"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "light"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "dark"})}
        class="flex p-2 cursor-pointer w-1/3"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
