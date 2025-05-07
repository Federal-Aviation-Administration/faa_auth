require "playwright"
Playwright.create(playwright_cli_executable_path: "f:/windows/tools/bin/playwright.exe") do |playwright|
  playwright.chromium.launch(headless: false) do |browser|
    page = browser.new_page
    page.goto("https://github.com/")

    form = page.query_selector("form.js-site-search-form")
    search_input = form.query_selector("input.header-search-input")
    search_input.click
    page.keyboard.type("playwright")
    page.expect_navigation {
      page.keyboard.press("Enter")
    }

    list = page.query_selector("ul.repo-list")
    items = list.query_selector_all("div.f4")
    items.each do |item|
      title = item.eval_on_selector("a", "a => a.innerText")
      puts("==> #{title}")
    end
  end
end
