# Rack::Attack — basic abuse protection.
#
# Throttle rules below are conservative defaults; tune per ops needs.
class Rack::Attack
  ### ── Configure the cache store ──────────────────────────────────────────
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### ── Allow localhost in development ─────────────────────────────────────
  if Rails.env.development?
    safelist("allow from localhost") do |req|
      "127.0.0.1" == req.ip || "::1" == req.ip
    end
  end

  ### ── Throttle free-copy requests ────────────────────────────────────────
  # Same IP can only submit 3 requests per hour. Stops bulk address-spam.
  throttle("free_copy_requests/ip", limit: 3, period: 1.hour) do |req|
    req.ip if req.path.match?(%r{^/[a-z]{2}/free_copy_requests}) && req.post?
  end

  ### ── Throttle subscribes ────────────────────────────────────────────────
  throttle("subscribes/ip", limit: 5, period: 1.hour) do |req|
    req.ip if req.path == "/subscribes" && req.post?
  end

  ### ── Block obvious vuln scanners ────────────────────────────────────────
  blocklist("block bad bots") do |req|
    req.path.match?(/\.(php|asp|cgi)$/i) ||
      req.path.start_with?("/wp-", "/wordpress")
  end

  ### ── Custom response when throttled ─────────────────────────────────────
  self.throttled_responder = lambda do |env|
    [
      429,
      { "Content-Type" => "text/html" },
      ["<h1>Slow down</h1><p>Too many requests. Try again in a bit.</p>"]
    ]
  end
end
