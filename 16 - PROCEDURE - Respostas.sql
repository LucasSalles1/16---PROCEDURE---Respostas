DROP DATABASE IF EXISTS db_stored_procedures;
CREATE DATABASE db_stored_procedures;
USE db_stored_procedures;


-- 1. TABELAS E DADOS DE TESTE
CREATE TABLE Padaria_Pao (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    preco DECIMAL(10,2),
    disponivel TINYINT(1)
);

CREATE TABLE Padaria_Ingrediente (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    id_fornecedor INT
);

CREATE TABLE Padaria_Produto (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    categoria VARCHAR(50),
    preco DECIMAL(10,2)
);

CREATE TABLE Padaria_Venda (
    id_venda INT PRIMARY KEY AUTO_INCREMENT,
    quantidade INT
);

CREATE TABLE Farmacia_Medicamento (
    id_medicamento INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    preco DECIMAL(10,2),
    estoque INT
);

CREATE TABLE Farmacia_Lote (
    id_lote INT PRIMARY KEY AUTO_INCREMENT,
    id_medicamento INT,
    num_lote VARCHAR(50),
    validade DATE
);

CREATE TABLE Agenc_Pacote (
    id_pacote INT PRIMARY KEY AUTO_INCREMENT,
    destino VARCHAR(100),
    preco DECIMAL(10,2),
    vagas INT
);

CREATE TABLE Agenc_Reserva (
    id_reserva INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT,
    id_pacote INT,
    data_reserva DATE
);

CREATE TABLE Agenc_Destino (
    id_destino INT PRIMARY KEY AUTO_INCREMENT,
    nome_destino VARCHAR(100),
    regiao VARCHAR(50)
);

CREATE TABLE Superm_Setor (
    id_setor INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100)
);

CREATE TABLE Superm_Produto (
    id_produto INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    id_setor INT,
    quantidade INT
);


INSERT INTO Padaria_Pao
VALUES
    (1, 'Pão Francês', 0.80, 1),
    (2, 'Pão Doce', 1.50, 0);

INSERT INTO Padaria_Ingrediente
VALUES
    (1, 'Farinha', 10),
    (2, 'Açúcar', 10);

INSERT INTO Padaria_Produto
VALUES
    (1, 'Suco', 'Bebidas', 5.00),
    (2, 'Refri', 'Bebidas', 8.00);

INSERT INTO Padaria_Venda
VALUES
    (1, 5),
    (2, 25),
    (3, 100);

INSERT INTO Farmacia_Medicamento
VALUES
    (1, 'Dipirona', 10.00, 50),
    (2, 'Paracetamol', 15.00, 5);

INSERT INTO Farmacia_Lote
VALUES
    (1, 1, 'L001', '2027-12-31'),
    (2, 1, 'L002', '2025-01-01');

INSERT INTO Agenc_Pacote
VALUES
    (1, 'Cancún', 1500.00, 10),
    (2, 'Paris', 4500.00, 0);

INSERT INTO Agenc_Reserva
VALUES
    (1, 101, 1, '2026-01-01');

INSERT INTO Agenc_Destino
VALUES
    (1, 'Salvador', 'Nordeste'),
    (2, 'Recife', 'Nordeste');

INSERT INTO Superm_Setor
VALUES
    (1, 'Hortifruti'),
    (2, 'Padaria');

INSERT INTO Superm_Produto
VALUES
    (1, 'Maçã', 1, 40),
    (2, 'Pão de Forma', 2, 15);


-- 2. PROCEDURES (1 A 20)
DELIMITER //

CREATE PROCEDURE sp_paes_disponiveis()
BEGIN
    SELECT nome, preco
    FROM Padaria_Pao
    WHERE disponivel = 1;
END //


CREATE PROCEDURE sp_ingredientes_por_fornecedor(IN p_id INT)
BEGIN
    SELECT *
    FROM Padaria_Ingrediente
    WHERE id_fornecedor = p_id;
END //


CREATE PROCEDURE sp_total_produtos_categoria(
    IN p_cat VARCHAR(50),
    OUT p_total INT
)
BEGIN
    SELECT COUNT(*)
    INTO p_total
    FROM Padaria_Produto
    WHERE categoria = p_cat;
END //


CREATE PROCEDURE sp_acrescimo_preco(INOUT p_preco DECIMAL(10,2))
BEGIN
    SET p_preco = p_preco * 1.05;
END //


CREATE PROCEDURE sp_classifica_venda_padaria(
    IN p_id INT,
    OUT p_class VARCHAR(20)
)
BEGIN
    DECLARE v_qtd INT;

    SELECT quantidade
    INTO v_qtd
    FROM Padaria_Venda
    WHERE id_venda = p_id;

    IF v_qtd <= 10 THEN
        SET p_class = 'Pequeno';
    ELSEIF v_qtd <= 50 THEN
        SET p_class = 'Médio';
    ELSE
        SET p_class = 'Grande';
    END IF;
END //


CREATE PROCEDURE sp_lotes_validos_medicamento(IN p_id INT)
BEGIN
    SELECT *
    FROM Farmacia_Lote
    WHERE id_medicamento = p_id
      AND validade > CURDATE();
END //


CREATE PROCEDURE sp_valor_total_estoque_med(
    IN p_id INT,
    OUT p_total DECIMAL(10,2)
)
BEGIN
    SELECT (preco * estoque)
    INTO p_total
    FROM Farmacia_Medicamento
    WHERE id_medicamento = p_id;
END //


CREATE PROCEDURE sp_atualiza_preco_medicamento(
    IN p_id INT,
    IN p_novo DECIMAL(10,2)
)
BEGIN
    UPDATE Farmacia_Medicamento
    SET preco = p_novo
    WHERE id_medicamento = p_id;
END //


CREATE PROCEDURE sp_verifica_estoque_medicamento(
    IN p_id INT,
    IN p_qtd INT,
    OUT p_status VARCHAR(50)
)
BEGIN
    DECLARE v_est INT;

    SELECT estoque
    INTO v_est
    FROM Farmacia_Medicamento
    WHERE id_medicamento = p_id;

    IF v_est >= p_qtd THEN
        SET p_status = 'Estoque Suficiente';
    ELSE
        SET p_status = 'Estoque Insuficiente';
    END IF;
END //


CREATE PROCEDURE sp_retira_medicamento(
    IN p_id INT,
    IN p_qtd INT
)
BEGIN
    DECLARE v_est INT;

    SELECT estoque
    INTO v_est
    FROM Farmacia_Medicamento
    WHERE id_medicamento = p_id;

    IF v_est >= p_qtd THEN
        UPDATE Farmacia_Medicamento
        SET estoque = estoque - p_qtd
        WHERE id_medicamento = p_id;
    ELSE
        SELECT 'Erro: Estoque insuficiente' AS erro;
    END IF;
END //


CREATE PROCEDURE sp_pacotes_disponiveis()
BEGIN
    SELECT *
    FROM Agenc_Pacote
    WHERE vagas > 0;
END //


CREATE PROCEDURE sp_reservas_cliente(IN p_id INT)
BEGIN
    SELECT *
    FROM Agenc_Reserva
    WHERE id_cliente = p_id;
END //


CREATE PROCEDURE sp_destinos_por_regiao(
    IN p_reg VARCHAR(50),
    OUT p_total INT
)
BEGIN
    SELECT COUNT(*)
    INTO p_total
    FROM Agenc_Destino
    WHERE regiao = p_reg;
END //


CREATE PROCEDURE sp_atualiza_preco_pacote(
    IN p_id INT,
    IN p_atual DECIMAL(10,2),
    IN p_novo DECIMAL(10,2)
)
BEGIN
    UPDATE Agenc_Pacote
    SET preco = p_novo
    WHERE id_pacote = p_id
      AND preco = p_atual;
END //


CREATE PROCEDURE sp_classifica_pacote(
    IN p_valor DECIMAL(10,2),
    OUT p_cat VARCHAR(20)
)
BEGIN
    IF p_valor <= 1500.00 THEN
        SET p_cat = 'Econômico';
    ELSEIF p_valor <= 4000.00 THEN
        SET p_cat = 'Padrão';
    ELSE
        SET p_cat = 'Premium';
    END IF;
END //


CREATE PROCEDURE sp_produtos_por_setor(IN p_id INT)
BEGIN
    SELECT *
    FROM Superm_Produto
    WHERE id_setor = p_id;
END //


CREATE PROCEDURE sp_converte_pacotes_dez(INOUT p_qtd INT)
BEGIN
    SET p_qtd = FLOOR(p_qtd / 10);
END //


CREATE PROCEDURE sp_atualiza_estoque_supermercado(
    IN p_id INT,
    IN p_nova INT
)
BEGIN
    IF p_nova >= 0 THEN
        UPDATE Superm_Produto
        SET quantidade = p_nova
        WHERE id_produto = p_id;
    ELSE
        SELECT 'Erro: Quantidade negativa' AS erro;
    END IF;
END //


CREATE PROCEDURE sp_exibe_codigo_procedure()
BEGIN
    SHOW CREATE PROCEDURE sp_paes_disponiveis;
END //


CREATE PROCEDURE sp_lista_procedures_banco()
BEGIN
    SELECT routine_name
    FROM information_schema.routines
    WHERE routine_schema = DATABASE()
      AND routine_type = 'PROCEDURE';
END //

DELIMITER ;


-- 3. TESTES DE EXECUÇÃO (CALL)
CALL sp_paes_disponiveis();
CALL sp_ingredientes_por_fornecedor(10);
CALL sp_total_produtos_categoria('Bebidas', @total_prod);
SELECT @total_prod AS total_bebidas;
SET @preco = 100.00;
CALL sp_acrescimo_preco(@preco);
SELECT @preco AS preco_acrescimo;
CALL sp_classifica_venda_padaria(2, @classificacao);
SELECT @classificacao AS tamanho_venda;
CALL sp_lotes_validos_medicamento(1);
CALL sp_valor_total_estoque_med(1, @total_est);
SELECT @total_est AS total_estoque;
CALL sp_atualiza_preco_medicamento(1, 12.50);
CALL sp_verifica_estoque_medicamento(1, 10, @status);
SELECT @status AS status_estoque;
CALL sp_retira_medicamento(1, 5);
CALL sp_pacotes_disponiveis();
CALL sp_reservas_cliente(101);
CALL sp_destinos_por_regiao('Nordeste', @total_dest);
SELECT @total_dest AS total_nordeste;
CALL sp_atualiza_preco_pacote(1, 1500.00, 1600.00);
CALL sp_classifica_pacote(4500.00, @cat);
SELECT @cat AS categoria_pacote;
CALL sp_produtos_por_setor(1);
SET @unidades = 45;
CALL sp_converte_pacotes_dez(@unidades);
SELECT @unidades AS pacotes_10;
CALL sp_atualiza_estoque_supermercado(1, 50);
CALL sp_exibe_codigo_procedure();
CALL sp_lista_procedures_banco();