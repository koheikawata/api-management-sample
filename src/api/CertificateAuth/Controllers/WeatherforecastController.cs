using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using CertificateAuth.Models;

namespace CertificateAuth.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WeatherforecastController : ControllerBase
    {
        [HttpGet("RequireAuth")]
        [Authorize]
        public ActionResult<Weatherforecast> GetServiceAuth()
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
                Country = "France",
                City = "Nice",
                TemperatureC = 28,
                Summary = "Sunny",
            };
            return weatherforecast;
        }
    }
}