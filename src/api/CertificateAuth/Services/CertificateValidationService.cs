using System.Security.Cryptography.X509Certificates;
using CertificateAuth.Interfaces;

namespace CertificateAuth.Services
{
    public class CertificateValidationService : ICertificateValidationService
    {
        private readonly IConfiguration configuration;

        public CertificateValidationService(IConfiguration configuration)
        {
            this.configuration = configuration;
        }

        public bool ValidateCertificate(X509Certificate2 clientCertificate)
        {
            X509Certificate2 expectedCertificate;
            string pfxFilePath = this.configuration.GetValue<string>("Certificate:PfxFilePath");
            string pfxFilePassword = this.configuration.GetValue<string>("Certificate:PfxFilePassword");

            if (File.Exists(Path.Combine(Directory.GetCurrentDirectory(), pfxFilePath)))
            {
                expectedCertificate = new X509Certificate2(
                    Path.Combine(Directory.GetCurrentDirectory(), pfxFilePath), pfxFilePassword);
                return clientCertificate.Thumbprint == expectedCertificate.Thumbprint;
            }
            else
            {
                return clientCertificate.Thumbprint == this.configuration.GetValue<string>("Certificate:Thumbprint");
            }
        }
    }
}
