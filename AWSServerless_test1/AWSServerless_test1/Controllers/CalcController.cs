using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;

namespace AWSServerless_test1.Controllers
{
    [ApiController]
    [EnableCors("corsapp")]
    [Route("api/[controller]")]
    public class CalcController : ControllerBase
    {
        private readonly ILogger<CalcController> _logger;

        public CalcController(ILogger<CalcController> logger) => _logger = logger;

        [HttpGet("add")]
        public IActionResult Add(int x, int y)
        {
            _logger.LogInformation($"{x} plus {y} is {x + y}");
            var json = new
            {
                time = DateTimeOffset.UtcNow,
                result = x + y
            };

            return Ok(new { results = json });
        }
    }
}
