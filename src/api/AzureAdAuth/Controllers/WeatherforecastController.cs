using AzureAdAuth.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AzureAdAuth.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WeatherforecastController : ControllerBase
    {
        [HttpGet("RequireAuth")]
        [Authorize]
        public ActionResult<Weatherforecast> GetAzureAdAuth()
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
                Country = "UK",
                City = "London",
                TemperatureC = 8,
                Summary = "Cloudy",
            };
            return weatherforecast;
        }
    }
}