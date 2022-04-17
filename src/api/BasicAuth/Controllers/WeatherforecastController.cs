using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using BasicAuth.CustomAttributes;
using BasicAuth.Models;

namespace BasicAuth.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WeatherforecastController : ControllerBase
    {
        [HttpGet("RequireAuth")]
        [AllowAnonymous]
        [AuthorizeBasicAuth]
        public ActionResult<Weatherforecast> GetBasicAuth()
        {
            Weatherforecast weatherforecast = new ()
            {
                Id = Guid.NewGuid().ToString(),
                Country = "Japan",
                City = "Tokyo",
                TemperatureC = 18,
                Summary = "Sunny",
            };
            return weatherforecast;
        }

        [HttpGet("NoAuth")]
        public ActionResult<Weatherforecast> Get()
        {
            Weatherforecast weatherforecast = new ()
            {
                Id = Guid.NewGuid().ToString(),
                Country = "New Zealand",
                City = "Nelson",
                TemperatureC = 15,
                Summary = "Sunny",
            };
            return weatherforecast;
        }
    }
}