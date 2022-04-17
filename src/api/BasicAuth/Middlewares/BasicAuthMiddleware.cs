using System.Net.Http.Headers;
using System.Text;

namespace BasicAuth.Middlewares
{
    public class BasicAuthMiddleware
    {
        private readonly RequestDelegate next;
        private readonly IConfiguration configuration;
        private readonly ILogger<BasicAuthMiddleware> logger;

        public BasicAuthMiddleware(RequestDelegate next, IConfiguration configuration, ILogger<BasicAuthMiddleware> logger)
        {
            this.next = next;
            this.configuration = configuration;
            this.logger = logger;
        }

        public async Task InvokeAsync(HttpContext httpContext)
        {
            string authHeader = httpContext.Request.Headers["Authorization"];
            if (authHeader != null)
            {
                AuthenticationHeaderValue authHeaderVal = AuthenticationHeaderValue.Parse(authHeader);
                if (authHeaderVal.Scheme.Equals("basic", StringComparison.OrdinalIgnoreCase) && authHeaderVal.Parameter != null)
                {
                    try
                    {
                        Encoding encoding = Encoding.GetEncoding("iso-8859-1");
                        string usernameAndPassword = encoding.GetString(Convert.FromBase64String(authHeaderVal.Parameter));
                        string username = usernameAndPassword.Split(new char[] { ':' })[0];
                        string password = usernameAndPassword.Split(new char[] { ':' })[1];
                        if (username == this.configuration.GetValue<string>("BasicAuth:UserName") && password == this.configuration.GetValue<string>("BasicAuth:Password"))
                        {
                            httpContext.Items["BasicAuth"] = true;
                        }
                    }
                    catch (Exception ex)
                    {
                        this.logger.LogError($"{ex.Message}");
                    }
                }
            }
            await this.next(httpContext).ConfigureAwait(false);
        }
    }
}
