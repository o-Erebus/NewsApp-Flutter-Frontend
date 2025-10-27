class Constants {
  static const String baseUrlTest = "http://10.0.0.4:10000";
  static const String baseUrlProd =
      "https://fyp-backend-dev-yoww.onrender.com";
  static const bool isProd = true;
  static final String baseUrl = isProd ? baseUrlProd : baseUrlTest;
  static const String articlesEndpoint = "/articles/";
  static const String featuredArticlesEndpoint = "/articles/featured";
  static const String globalArticlesEndpoint = "/articles/";

  // AI Analysis endpoints
  // Unified endpoint for comprehensive article analysis (summary, political bias, emotional analysis)
  // POST expects either article_id or article_text
  static const String aiAnalyzeEndpoint = "/ai/analyze";

  // User-related endpoints
  static const String userHistoryEndpoint = "/users/history";

  static const String secretKey = "sk_7b6a1f8c9d4e2f5a8b3c1e7d9f0a4b6c";
  static const String featuredArticlesSize = "5";
  static const String pageSize = "10";
  static const double buttonHeight = 52.0;
}
