class MyApp
  def call(env)
    [200, {"Content-Type" => "text/html"}, [""]]
  end
end
