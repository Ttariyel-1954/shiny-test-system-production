-- Test sistemi üçün əsas cədvəllər

-- İstifadəçilər cədvəli
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) UNIQUE NOT NULL,
    network_id INTEGER NOT NULL,
    computer_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Test sualları cədvəli
CREATE TABLE IF NOT EXISTS questions (
    id SERIAL PRIMARY KEY,
    question_text TEXT NOT NULL,
    option_a VARCHAR(500) NOT NULL,
    option_b VARCHAR(500) NOT NULL,
    option_c VARCHAR(500) NOT NULL,
    option_d VARCHAR(500) NOT NULL,
    correct_answer CHAR(1) NOT NULL CHECK (correct_answer IN ('A', 'B', 'C', 'D')),
    category VARCHAR(100) NOT NULL,
    difficulty_level INTEGER DEFAULT 1 CHECK (difficulty_level BETWEEN 1 AND 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Test nəticələri cədvəli
CREATE TABLE IF NOT EXISTS test_results (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    test_session_id VARCHAR(100) NOT NULL,
    question_id INTEGER REFERENCES questions(id),
    selected_answer CHAR(1) CHECK (selected_answer IN ('A', 'B', 'C', 'D')),
    is_correct BOOLEAN NOT NULL,
    answer_time INTEGER, -- saniyələrlə cavab verme müddəti
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Test sessiyaları cədvəli
CREATE TABLE IF NOT EXISTS test_sessions (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(100) UNIQUE NOT NULL,
    user_id INTEGER REFERENCES users(id),
    total_questions INTEGER NOT NULL DEFAULT 0,
    correct_answers INTEGER NOT NULL DEFAULT 0,
    total_time INTEGER, -- ümumi vaxt saniyələrlə
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'abandoned')),
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

-- Demo məlumatlar daxil edin
INSERT INTO users (username, full_name, email, network_id, computer_id) VALUES 
('admin', 'System Administrator', 'admin@testapp.local', 0, 0),
('test_user_1_1', 'Test User Network 1 PC 1', 'user1_1@test.local', 1, 1),
('test_user_1_2', 'Test User Network 1 PC 2', 'user1_2@test.local', 1, 2),
('test_user_2_1', 'Test User Network 2 PC 1', 'user2_1@test.local', 2, 1);

INSERT INTO questions (question_text, option_a, option_b, option_c, option_d, correct_answer, category, difficulty_level) VALUES 
('Azərbaycanın paytaxtı hansı şəhərdir?', 'Gəncə', 'Bakı', 'Sumqayıt', 'Şəki', 'B', 'Coğrafiya', 1),
('2 + 2 = ?', '3', '4', '5', '6', 'B', 'Riyaziyyat', 1),
('Hansı il Azərbaycan müstəqillik elan etdi?', '1990', '1991', '1992', '1993', 'B', 'Tarix', 2),
('Kompüterdə məlumatları saxlamaq üçün istifadə olunan əsas yaddaş vahidi hansıdır?', 'Bit', 'Byte', 'Kilobyte', 'Megabyte', 'B', 'İnformatika', 2),
('HTML-də səhifənin başlığını təyin etmək üçün hansı teqdən istifadə olunur?', '<head>', '<title>', '<header>', '<h1>', 'B', 'İnformatika', 3);

-- İndekslər yaradın (performans üçün)
CREATE INDEX idx_users_network_computer ON users(network_id, computer_id);
CREATE INDEX idx_test_results_user_session ON test_results(user_id, test_session_id);
CREATE INDEX idx_test_sessions_user ON test_sessions(user_id);
CREATE INDEX idx_test_sessions_status ON test_sessions(status);
CREATE INDEX idx_questions_category ON questions(category);

-- Statistika view yaradın
CREATE VIEW user_statistics AS
SELECT 
    u.id,
    u.username,
    u.network_id,
    u.computer_id,
    COUNT(DISTINCT ts.id) as total_tests,
    AVG(CASE WHEN ts.status = 'completed' THEN ts.correct_answers::float / ts.total_questions * 100 END) as avg_score,
    MAX(ts.completed_at) as last_test_date
FROM users u 
LEFT JOIN test_sessions ts ON u.id = ts.user_id
GROUP BY u.id, u.username, u.network_id, u.computer_id;

COMMENT ON TABLE users IS 'İstifadəçilər məlumatları - 20 şəbəkə x 30 kompüter';
COMMENT ON TABLE questions IS 'Test sualları və cavabları';
COMMENT ON TABLE test_results IS 'Hər sualın cavab nəticələri';
COMMENT ON TABLE test_sessions IS 'Test sessiyalarının ümumi statistikası';
COMMENT ON VIEW user_statistics IS 'İstifadəçi statistikalarının xülasəsi';

-- Məlumatların daxil edildiyi haqqında məlumat
SELECT 'Database initialized successfully!' as status;
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_questions FROM questions;
