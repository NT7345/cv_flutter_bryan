if (preg_match('#^/accounts/(\d+)/profile$#', $path, $matches)) {
    $controller = new \App\Controllers\ProfileController();
    $accountId = (int) $matches[1];
    match ($method) {
        'GET' => $controller->show($accountId),
        'PUT', 'POST' => $controller->update($accountId),
        default => methodNotAllowed(),
    };
    exit;
}
