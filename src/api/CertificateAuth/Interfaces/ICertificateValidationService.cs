using System.Security.Cryptography.X509Certificates;

namespace CertificateAuth.Interfaces
{
    public interface ICertificateValidationService
    {
        public bool ValidateCertificate(X509Certificate2 clientCertificate);
    }
}
