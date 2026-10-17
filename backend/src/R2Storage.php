<?php

namespace App;

use Aws\S3\S3Client;
use RuntimeException;

class R2Storage
{
    private S3Client $client;
    private string $bucket;

    public function __construct()
    {
        $accountId = trim((string) env('R2_ACCOUNT_ID', ''));
        $accessKeyId = trim((string) env('R2_ACCESS_KEY_ID', ''));
        $secretAccessKey = trim((string) env('R2_SECRET_ACCESS_KEY', ''));
        $this->bucket = trim((string) env('R2_BUCKET_NAME', ''));

        if (!$accountId || !$accessKeyId || !$secretAccessKey || !$this->bucket) {
            throw new RuntimeException('Falta configurar el almacenamiento R2');
        }

        $this->client = new S3Client([
            'version' => 'latest',
            'region' => 'auto',
            'endpoint' => "https://{$accountId}.r2.cloudflarestorage.com",
            'use_path_style_endpoint' => true,
            'credentials' => [
                'key' => $accessKeyId,
                'secret' => $secretAccessKey,
            ],
        ]);
    }

    public function guardar(string $clave, string $contenido, string $tipoContenido): void
    {
        $this->client->putObject([
            'Bucket' => $this->bucket,
            'Key' => $clave,
            'Body' => $contenido,
            'ContentType' => $tipoContenido,
            'CacheControl' => 'private, max-age=300',
        ]);
    }

    /** @return array{contenido: string, tipo_contenido: string} */
    public function obtener(string $clave): array
    {
        $objeto = $this->client->getObject([
            'Bucket' => $this->bucket,
            'Key' => $clave,
        ]);

        return [
            'contenido' => $objeto['Body']->getContents(),
            'tipo_contenido' => (string) $objeto['ContentType'],
        ];
    }

    public function eliminar(string $clave): void
    {
        $this->client->deleteObject([
            'Bucket' => $this->bucket,
            'Key' => $clave,
        ]);
    }
}
