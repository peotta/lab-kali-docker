<?php
$erro = "";
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $usuario = $_POST["usuario"] ?? "";
    $senha = $_POST["senha"] ?? "";
    if ($usuario === "admin" && $senha === "password123") {
        echo "<h2>Login efetuado com sucesso!</h2><p>Bem-vindo, admin.</p>";
        exit;
    } else {
        $erro = "Usuário ou senha incorretos.";
    }
}
?>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Portal do Laboratório</title>
</head>
<body>
    <h1>Portal do Laboratório</h1>
    <?php if ($erro): ?>
        <p style="color:red;"><?php echo htmlspecialchars($erro); ?></p>
    <?php endif; ?>
    <form method="POST" action="">
        <label>Usuário: <input type="text" name="usuario"></label><br><br>
        <label>Senha: <input type="password" name="senha"></label><br><br>
        <input type="submit" value="Entrar">
    </form>
</body>
</html>
