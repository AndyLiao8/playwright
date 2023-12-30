using Microsoft.AspNetCore.Mvc;
using Microsoft.Playwright;
using TimeZoneConverter;

namespace playwright.Controllers
{
    [ApiController]
    public class PDFController : Controller
    {
        [HttpGet]
        [Route("pdf")]
        public async Task<IActionResult> Index()
        {
            var info = TZConvert.GetTimeZoneInfo("Eastern Standard Time");
            using var playwright = await Playwright.CreateAsync();
            await using var browser = await playwright.Chromium.LaunchAsync();
            var page = await browser.NewPageAsync();
            await page.GotoAsync("https://www.baidu.com");
            var datas = await page.PdfAsync();
            return File(datas, "application/pdf",$"test_{info.DaylightName}.pdf");

        }
    }
}
