using System.ComponentModel.DataAnnotations;

namespace BasicAuth.Models
{
    public class Weatherforecast
    {
        [Key]
        public string? Id { get; set; }
        public string? Country { get; set; }
        public string? City { get; set; }
        public int TemperatureC { get; set; }
        public string? Summary { get; set; }
    }
}
