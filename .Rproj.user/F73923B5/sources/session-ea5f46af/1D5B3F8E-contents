
# SQLite ilə Təhsil Test Sistemi
library(shiny)
library(DBI)
library(RSQLite)
library(shinydashboard)
library(DT)

# SQLite verilənlər bazası faylı
DB_FILE <- "education_test.db"

# Verilənlər bazası bağlantısı
get_db_connection <- function() {
  tryCatch({
    con <- dbConnect(RSQLite::SQLite(), DB_FILE)
    return(con)
  }, error = function(e) {
    return(NULL)
  })
}

# Verilənlər bazası cədvəllərini yaratmaq funksiyası
create_database_tables <- function() {
  con <- get_db_connection()
  if(is.null(con)) return(FALSE)
  
  tryCatch({
    # Fənnlər cədvəli
    dbExecute(con, "
      CREATE TABLE IF NOT EXISTS subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_name TEXT NOT NULL,
        subject_code TEXT NOT NULL,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ")
    
    # Suallar cədvəli
    dbExecute(con, "
      CREATE TABLE IF NOT EXISTS questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject_id INTEGER,
        question_text TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        difficulty_level INTEGER DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (subject_id) REFERENCES subjects(id)
      )
    ")
    
    # Məktəblər cədvəli
    dbExecute(con, "
      CREATE TABLE IF NOT EXISTS schools (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        school_name TEXT NOT NULL,
        city TEXT,
        region TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ")
    
    # Test nəticələri cədvəli
    dbExecute(con, "
      CREATE TABLE IF NOT EXISTS test_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_name TEXT NOT NULL,
        class_level INTEGER NOT NULL,
        school_id INTEGER,
        subject_id INTEGER,
        computer_number INTEGER,
        total_questions INTEGER,
        correct_answers INTEGER,
        percentage REAL,
        duration_seconds INTEGER,
        answers TEXT,
        test_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (school_id) REFERENCES schools(id),
        FOREIGN KEY (subject_id) REFERENCES subjects(id)
      )
    ")
    
    dbDisconnect(con)
    return(TRUE)
  }, error = function(e) {
    if(!is.null(con)) dbDisconnect(con)
    return(FALSE)
  })
}

# Nümunə məlumatları əlavə etmək
insert_sample_data <- function() {
  con <- get_db_connection()
  if(is.null(con)) return(FALSE)
  
  tryCatch({
    # Məlumat varmı yoxla
    existing <- dbGetQuery(con, "SELECT COUNT(*) as count FROM subjects")
    if(existing$count > 0) {
      dbDisconnect(con)
      return(TRUE)
    }
    
    # Fənnləri əlavə et
    subjects_data <- data.frame(
      subject_name = c("Riyaziyyat", "Fizika", "Kimya", "Biologiya", "Tarix", 
                       "Coğrafiya", "Ədəbiyyat", "İngilis dili", "İnformatika", "Fəlsəfə"),
      subject_code = c("MATH", "PHYS", "CHEM", "BIOL", "HIST", 
                       "GEOG", "LIT", "ENG", "IT", "PHIL"),
      description = c("Ümumi riyaziyyat sualları", "Fizika qanunları və düsturlar",
                      "Kimyəvi elementlər və reaksiyalar", "Canlılar aləmi haqqında",
                      "Azərbaycan və dünya tarixi", "Dünya coğrafiyası və təbiət",
                      "Azərbaycan ədəbiyyatı", "İngilis dili qrammatikası",
                      "Kompüter elmləri", "Fəlsəfə tarixi və məntiq")
    )
    
    dbWriteTable(con, "subjects", subjects_data, append = TRUE, row.names = FALSE)
    
    # Məktəbləri əlavə et
    schools_data <- data.frame(
      school_name = c("Bakı Təhsil Kompleksi", "Gəncə Respublika Gimnaziyası",
                      "Sumqayıt Şəhər Lisey", "Şəki Humanitar Gimnaziya",
                      "Lənkəran İxtisaslaşmış Məktəb", "Şirvan Elm Lisey",
                      "Mingəçevir Texniki Lisey", "Naxçıvan Dövlət Gimnaziyası",
                      "Qəbələ Təbiət Lisey", "Quba Dağ Məktəbi"),
      city = c("Bakı", "Gəncə", "Sumqayıt", "Şəki", "Lənkəran",
               "Şirvan", "Mingəçevir", "Naxçıvan", "Qəbələ", "Quba"),
      region = c("Bakı", "Gəncə-Qazax", "Abşeron", "Şəki-Zaqatala", "Lənkəran",
                 "Şirvan", "Aran", "Naxçıvan", "Quba-Xaçmaz", "Quba-Xaçmaz")
    )
    
    dbWriteTable(con, "schools", schools_data, append = TRUE, row.names = FALSE)
    
    # Riyaziyyat sualları
    math_questions <- data.frame(
      subject_id = rep(1, 20),
      question_text = c(
        "12 + 15 × 3 = ?",
        "√64 = ?",
        "2x + 5 = 17 olduqda x = ?",
        "sin(30°) = ?",
        "log₁₀(100) = ?",
        "3! = ?",
        "Dairənin sahəsi (r=5) = ?",
        "2⁵ = ?",
        "(-3)² = ?",
        "15% -i 200-dən = ?",
        "3x - 7 = 2x + 5 olduqda x = ?",
        "cos(60°) = ?",
        "5x + 3y = 15 və x = 0 olduqda y = ?",
        "2/3 + 1/4 = ?",
        "Kvadratın diaqonalı (tərəf=4) = ?",
        "|(-5)| = ?",
        "8 × (3 + 2) = ?",
        "25 ÷ 5² = ?",
        "x² = 16 olduqda x = ?",
        "Trapesiyada orta xətt (a=6, b=4) = ?"
      ),
      option_a = c("57", "6", "6", "0.5", "2", "6", "25π", "32", "9", "30", 
                   "12", "0.5", "5", "11/12", "4√2", "5", "40", "1", "±4", "5"),
      option_b = c("51", "8", "7", "1/2", "10", "9", "78.5", "10", "-9", "15", 
                   "8", "1/2", "3", "5/6", "8", "-5", "25", "5", "4", "10"),
      option_c = c("45", "4", "5", "√3/2", "1", "3", "50", "16", "6", "3", 
                   "15", "√3/2", "15", "7/12", "5.66", "0", "13", "25", "-4", "4"),
      option_d = c("60", "16", "8", "1", "0", "12", "100", "8", "-6", "45", 
                   "5", "1", "0", "1/2", "6", "|5|", "35", "0.2", "16", "8"),
      correct_answer = c("A", "B", "A", "B", "A", "A", "B", "A", "A", "A",
                         "A", "B", "A", "A", "B", "A", "A", "A", "A", "A"),
      difficulty_level = c(1,1,2,3,2,1,2,1,1,1,2,3,2,2,3,1,1,1,2,2)
    )
    
    # Fizika sualları
    physics_questions <- data.frame(
      subject_id = rep(2, 15),
      question_text = c(
        "Səs dalğalarının havadakı sürəti təxminən neçədir?",
        "İşığın vakuumdakı sürəti = ?",
        "F = ma düsturu kimə aiddir?",
        "Elektrik enerjisinin ölçü vahidi nədir?",
        "Arximed qanunu nə ilə bağlıdır?",
        "Ohm qanunu: V = ?",
        "Gravitasiya təcili Yer üzərində = ?",
        "Elektrik yükünün ölçü vahidi = ?",
        "Güc düsturu P = ?",
        "Kinetik enerji Ek = ?",
        "Dalğa uzunluğu və tezlik: λ × f = ?",
        "Coulomb qanunu nə təsvir edir?",
        "Termodinamikanın I qanunu nəyi ifadə edir?",
        "Magnetik sahənin ölçü vahidi = ?",
        "Planck sabiti h = ?"
      ),
      option_a = c("340 m/s", "3×10⁸ m/s", "Nyuton", "Vatt", "Üzmə", "IR", 
                   "9.8 m/s²", "Kulon", "W/t", "mv²/2", "v", "Elektrik qüvvə",
                   "Enerji saxlanması", "Tesla", "6.63×10⁻³⁴ J·s"),
      option_b = c("300 m/s", "3×10⁶ m/s", "Eynşteyn", "Coul", "Batma", "I/R",
                   "10 m/s²", "Amper", "Ft", "mv²", "c", "Magnetik qüvvə",
                   "İmpuls saxlanması", "Veber", "1.6×10⁻¹⁹ J·s"),
      option_c = c("1500 m/s", "3×10¹⁰ m/s", "Qaliley", "Joule", "Çəkmə", "V/I",
                   "8.8 m/s²", "Farad", "UI", "m²v/2", "a", "Çəkimə qüvvə",
                   "Kütlə saxlanması", "Henri", "9.1×10⁻³¹ J·s"),
      option_d = c("500 m/s", "3×10⁴ m/s", "Kepler", "Kalori", "İtələmə", "R/V",
                   "12 m/s²", "Volt", "mgh", "mv/2", "E", "Sürtünmə qüvvə",
                   "Zaman saxlanması", "Om", "2.99×10⁸ J·s"),
      correct_answer = c("A", "A", "A", "C", "A", "A", "A", "A", "C", "A",
                         "B", "A", "A", "A", "A"),
      difficulty_level = c(1,2,1,2,1,2,1,1,2,2,3,3,3,2,3)
    )
    
    # Kimya sualları
    chemistry_questions <- data.frame(
      subject_id = rep(3, 15),
      question_text = c(
        "Suyun kimyəvi düsturu nədir?",
        "Duz turşusunun düsturu = ?",
        "Oksigenin atom nömrəsi = ?",
        "Mendeleyev cədvəlində neçə element var?",
        "pH = 7 nə deməkdir?",
        "Karbonun valensliyi = ?",
        "NaCl nədir?",
        "Qızılın kimyəvi simvolu = ?",
        "H₂SO₄ nədir?",
        "Avogadro ədədi = ?",
        "Benzolun düsturu C₆H₆ doğrudur?",
        "Elektroliz nə prosesidir?",
        "Kataliza nə deməkdir?",
        "pH < 7 olan məhlul = ?",
        "İon nədir?"
      ),
      option_a = c("H2O", "HCl", "8", "118", "Neytral", "4", "Duz", "Au", 
                   "Sulfat turşu", "6.02×10²³", "Bəli", "Kimyəvi parçalanma",
                   "Reaksiyanın sürətlənməsi", "Turş", "Yüklənmiş atom"),
      option_b = c("H2O2", "H2SO4", "6", "92", "Turş", "2", "Şəkər", "Ag",
                   "Duz turşusu", "3.14×10⁸", "Xeyr", "Fiziki parçalanma",
                   "Reaksiyanın yavaşlaması", "Qələvi", "Neytral atom"),
      option_c = c("HO2", "HNO3", "16", "109", "Qələvi", "6", "Turşu", "Al",
                   "Azot turşusu", "2.71×10⁸", "Dəqiq deyil", "Elektrik parçalanma",
                   "Temperaturu artırma", "Neytral", "Molekul"),
      option_d = c("H3O", "CH3COOH", "12", "103", "Dəyişkən", "8", "Maye", "Ar",
                   "Sirkə turşusu", "1.38×10²³", "Məlum deyil", "Işıq parçalanma",
                   "Təzyiqi artırma", "Qarışıq", "Radikal"),
      correct_answer = c("A", "A", "A", "A", "A", "A", "A", "A", "A", "A",
                         "A", "C", "A", "A", "A"),
      difficulty_level = c(1,1,1,2,2,2,1,1,1,3,2,3,2,2,2)
    )
    
    # Sualları əlavə et
    all_questions <- rbind(math_questions, physics_questions, chemistry_questions)
    dbWriteTable(con, "questions", all_questions, append = TRUE, row.names = FALSE)
    
    dbDisconnect(con)
    return(TRUE)
  }, error = function(e) {
    if(!is.null(con)) dbDisconnect(con)
    return(FALSE)
  })
}

# Fənnləri gətir
get_subjects <- function() {
  con <- get_db_connection()
  if(is.null(con)) return(data.frame())
  
  subjects <- dbGetQuery(con, "SELECT * FROM subjects ORDER BY subject_name")
  dbDisconnect(con)
  return(subjects)
}

# Məktəbləri gətir
get_schools <- function() {
  con <- get_db_connection()
  if(is.null(con)) return(data.frame())
  
  schools <- dbGetQuery(con, "SELECT * FROM schools ORDER BY school_name")
  dbDisconnect(con)
  return(schools)
}

# Müəyyən fənn üzrə sualları gətir
get_questions_by_subject <- function(subject_id, limit = 20) {
  con <- get_db_connection()
  if(is.null(con)) return(data.frame())
  
  query <- paste0("SELECT * FROM questions WHERE subject_id = ", subject_id,
                  " ORDER BY RANDOM() LIMIT ", limit)
  questions <- dbGetQuery(con, query)
  dbDisconnect(con)
  return(questions)
}

# Test nəticəsini saxla
save_test_result <- function(result_data) {
  con <- get_db_connection()
  if(is.null(con)) return(FALSE)
  
  tryCatch({
    dbWriteTable(con, "test_results", result_data, append = TRUE, row.names = FALSE)
    dbDisconnect(con)
    return(TRUE)
  }, error = function(e) {
    if(!is.null(con)) dbDisconnect(con)
    return(FALSE)
  })
}

# UI
ui <- dashboardPage(
  dashboardHeader(title = "Azərbaycan Təhsil Test Sistemi"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Test", tabName = "test", icon = icon("pencil-alt")),
      menuItem("Nəticələr", tabName = "results", icon = icon("chart-bar")),
      menuItem("Statistika", tabName = "stats", icon = icon("chart-line"))
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .question-panel { 
          background-color: #f8f9fa; 
          padding: 20px; 
          border-radius: 10px; 
          margin-bottom: 20px; 
        }
        .timer-display {
          background: linear-gradient(45deg, #007bff, #28a745);
          color: white;
          padding: 15px;
          border-radius: 10px;
          text-align: center;
          margin-bottom: 20px;
        }
        .progress-box {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
          padding: 15px;
          border-radius: 10px;
          text-align: center;
        }
      "))
    ),
    
    tabItems(
      # Test bölməsi
      tabItem(tabName = "test",
              fluidRow(
                # Sol panel - Şagird məlumatları
                column(4,
                       box(title = "Şagird Məlumatları", status = "primary", 
                           solidHeader = TRUE, width = NULL,
                           
                           textInput("name", "Adınız və Soyadınız:", 
                                     placeholder = "Məsələn: Əli Məmmədov"),
                           
                           selectInput("class", "Sinifiniz:", 
                                       choices = c("Seçin" = "", 
                                                   "6-cı sinif" = "6",
                                                   "7-ci sinif" = "7", 
                                                   "8-ci sinif" = "8",
                                                   "9-cu sinif" = "9", 
                                                   "10-cu sinif" = "10", 
                                                   "11-ci sinif" = "11"),
                                       selected = ""),
                           
                           selectInput("school", "Məktəbiniz:", 
                                       choices = c("Seçin" = "",
                                                   "Bakı Təhsil Kompleksi" = "1",
                                                   "Gəncə Respublika Gimnaziyası" = "2",
                                                   "Sumqayıt Şəhər Lisey" = "3",
                                                   "Şəki Humanitar Gimnaziya" = "4",
                                                   "Lənkəran İxtisaslaşmış Məktəb" = "5",
                                                   "Şirvan Elm Lisey" = "6",
                                                   "Mingəçevir Texniki Lisey" = "7",
                                                   "Naxçıvan Dövlət Gimnaziyası" = "8",
                                                   "Qəbələ Təbiət Lisey" = "9",
                                                   "Quba Dağ Məktəbi" = "10"),
                                       selected = ""),
                           
                           selectInput("subject", "Fənni seçin:", 
                                       choices = c("Seçin" = "",
                                                   "Riyaziyyat" = "1",
                                                   "Fizika" = "2", 
                                                   "Kimya" = "3",
                                                   "Biologiya" = "4",
                                                   "Tarix" = "5",
                                                   "Coğrafiya" = "6",
                                                   "Ədəbiyyat" = "7",
                                                   "İngilis dili" = "8",
                                                   "İnformatika" = "9",
                                                   "Fəlsəfə" = "10"),
                                       selected = ""),
                           
                           numericInput("num_questions", "Sual sayı:", 
                                        value = 10, min = 5, max = 50, step = 5),
                           
                           numericInput("computer", "Kompüter nömrəsi:", 
                                        value = 1, min = 1, max = 100),
                           
                           hr(),
                           
                           actionButton("start", "Testə Başla", 
                                        class = "btn-success btn-lg", 
                                        style = "width: 100%; margin-bottom: 10px;"),
                           
                           actionButton("init_db", "Verilənlər Bazasını Hazırla", 
                                        class = "btn-info btn-sm", 
                                        style = "width: 100%;")
                       ),
                       
                       # Timer
                       conditionalPanel(
                         condition = "output.show_timer == true",
                         div(class = "timer-display",
                             h4("Qalan Vaxt:"),
                             h2(textOutput("timer_display"))
                         )
                       )
                ),
                
                # Sağ panel - Test sahəsi
                column(8,
                       conditionalPanel(
                         condition = "output.test_started == true",
                         box(title = textOutput("question_title"), status = "success", 
                             solidHeader = TRUE, width = NULL,
                             
                             div(class = "question-panel",
                                 h4(textOutput("question_text")),
                                 
                                 br(),
                                 radioButtons("answer", 
                                              h5("Cavabınızı seçin:"),
                                              choices = c("Test başladıqdan sonra suallar görünəcək" = ""),
                                              selected = character(0)),
                                 
                                 hr(),
                                 fluidRow(
                                   column(3, 
                                          actionButton("prev", "Əvvəlki", 
                                                       class = "btn-warning", style = "width: 100%;")),
                                   column(3,
                                          actionButton("next_btn", "Növbəti", 
                                                       class = "btn-primary", style = "width: 100%;")),
                                   column(3,
                                          actionButton("finish", "Bitir", 
                                                       class = "btn-danger", style = "width: 100%;")),
                                   column(3,
                                          actionButton("pause", "Pauza", 
                                                       class = "btn-secondary", style = "width: 100%;"))
                                 )
                             )
                         )
                       ),
                       
                       # Proqres və cavab varəqi
                       conditionalPanel(
                         condition = "output.test_started == true",
                         box(title = "Test Vəziyyəti", status = "info", 
                             solidHeader = TRUE, width = NULL,
                             
                             div(class = "progress-box",
                                 h4(textOutput("progress_text")),
                                 textOutput("subject_info")
                             ),
                             
                             br(),
                             h5("Cavab Vərəqi:"),
                             div(style = "font-family: monospace; background: #e9ecef; 
                             padding: 15px; border-radius: 5px; font-size: 14px;",
                                 verbatimTextOutput("answers_display")
                             )
                         )
                       ),
                       
                       # Nəticə paneli
                       conditionalPanel(
                         condition = "output.test_finished == true",
                         box(title = "Test Tamamlandı!", status = "success", 
                             solidHeader = TRUE, width = NULL,
                             
                             div(style = "text-align: center; padding: 20px;",
                                 div(style = "background: linear-gradient(45deg, #28a745, #20c997); 
                                 color: white; padding: 20px; border-radius: 15px; margin-bottom: 20px;",
                                     h3(textOutput("final_score")),
                                     h4(textOutput("final_percentage"))
                                 ),
                                 
                                 h5("Təfərrüatlı Nəticə:"),
                                 DT::dataTableOutput("result_details"),
                                 
                                 br(),
                                 actionButton("restart", "Yeni Test Başlat", 
                                              class = "btn-primary btn-lg",
                                              style = "font-size: 18px; padding: 15px 30px;")
                             )
                         )
                       )
                )
              )
      ),
      
      # Nəticələr bölməsi
      tabItem(tabName = "results",
              fluidRow(
                column(12,
                       box(title = "Son Test Nəticələri", status = "primary", 
                           solidHeader = TRUE, width = NULL,
                           DT::dataTableOutput("all_results")
                       )
                )
              )
      ),
      
      # Statistika bölməsi
      tabItem(tabName = "stats",
              fluidRow(
                column(6,
                       box(title = "Fənn üzrə Statistika", status = "info", 
                           solidHeader = TRUE, width = NULL,
                           plotOutput("subject_stats")
                       )
                ),
                column(6,
                       box(title = "Məktəb Reytinqi", status = "warning", 
                           solidHeader = TRUE, width = NULL,
                           plotOutput("school_ranking")
                       )
                )
              )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Reaktiv dəyərlər
  vals <- reactiveValues(
    current_q = 1,
    answers = c(),
    questions = data.frame(),
    started = FALSE,
    finished = FALSE,
    paused = FALSE,
    start_time = NULL,
    score = 0,
    time_remaining = 1800,
    total_questions = 10
  )
  
  # İlkin yüklənmə - sadəcə bildiriş göstər
  observeEvent(once = TRUE, eventExpr = TRUE, {
    showNotification("Sistem hazırdır!", type = "message", duration = 3)
  })
  
  # Verilənlər bazasını hazırla
  observeEvent(input$init_db, {
    showNotification("Verilənlər bazası yenilənir...", type = "message")
    
    if(create_database_tables()) {
      if(insert_sample_data()) {
        showNotification("Verilənlər bazası uğurla yeniləndi!", type = "message")
        
        # PostgreSQL seçimləri yenilə
        subjects <- get_subjects()
        schools <- get_schools()
        
        if(nrow(subjects) > 0) {
          choices <- setNames(subjects$id, subjects$subject_name)
          updateSelectInput(session, "subject", choices = c("Seçin" = "", choices))
        }
        
        if(nrow(schools) > 0) {
          choices <- setNames(schools$id, schools$school_name)
          updateSelectInput(session, "school", choices = c("Seçin" = "", choices))
        }
      } else {
        showNotification("Nümunə məlumatları əlavə edilmədi!", type = "error")
      }
    } else {
      showNotification("Verilənlər bazası yaradıla bilmədi!", type = "error")
    }
  })
  
  # Test başlat
  observeEvent(input$start, {
    # Validasiya
    if(is.null(input$name) || input$name == "") {
      showNotification("Adınızı və soyadınızı yazın!", type = "error")
      return()
    }
    if(is.null(input$class) || input$class == "") {
      showNotification("Sinifinizi seçin!", type = "error")
      return()
    }
    if(is.null(input$school) || input$school == "") {
      showNotification("Məktəbinizi seçin!", type = "error")
      return()
    }
    if(is.null(input$subject) || input$subject == "") {
      showNotification("Fənni seçin!", type = "error")
      return()
    }
    
    # Əvvəlcə PostgreSQL-dan sualları götürməyə çalış
    questions <- get_questions_by_subject(input$subject, input$num_questions)
    
    # Əgər PostgreSQL işləmirsə, hardcode suallarla test et
    if(nrow(questions) == 0) {
      # PostgreSQL işləmirsə, nümunə suallar
      if(input$subject == "1") { # Riyaziyyat
        questions <- data.frame(
          id = 1:10,
          subject_id = 1,
          question_text = c(
            "12 + 15 × 3 = ?",
            "√64 = ?", 
            "2x + 5 = 17 olduqda x = ?",
            "sin(30°) = ?",
            "log₁₀(100) = ?",
            "3! = ?",
            "(-3)² = ?",
            "15% -i 200-dən = ?",
            "cos(60°) = ?",
            "x² = 16 olduqda x = ?"
          ),
          option_a = c("57", "6", "6", "0.5", "2", "6", "9", "30", "0.5", "±4"),
          option_b = c("51", "8", "7", "1/2", "10", "9", "-9", "15", "1/2", "4"),
          option_c = c("45", "4", "5", "√3/2", "1", "3", "6", "3", "√3/2", "-4"),
          option_d = c("60", "16", "8", "1", "0", "12", "-6", "45", "1", "16"),
          correct_answer = c("A", "B", "A", "B", "A", "A", "A", "A", "B", "A"),
          difficulty_level = c(1, 1, 2, 3, 2, 1, 1, 1, 3, 2),
          stringsAsFactors = FALSE
        )
      } else if(input$subject == "2") { # Fizika
        questions <- data.frame(
          id = 1:8,
          subject_id = 2,
          question_text = c(
            "Səs dalğalarının havadakı sürəti təxminən neçədir?",
            "İşığın vakuumdakı sürəti = ?",
            "F = ma düsturu kimə aiddir?",
            "Elektrik enerjisinin ölçü vahidi nədir?",
            "Arximed qanunu nə ilə bağlıdır?",
            "Ohm qanunu: V = ?",
            "Gravitasiya təcili Yer üzərində = ?",
            "Elektrik yükünün ölçü vahidi = ?"
          ),
          option_a = c("340 m/s", "3×10⁸ m/s", "Nyuton", "Vatt", "Üzmə", "IR", "9.8 m/s²", "Kulon"),
          option_b = c("300 m/s", "3×10⁶ m/s", "Eynşteyn", "Coul", "Batma", "I/R", "10 m/s²", "Amper"),
          option_c = c("1500 m/s", "3×10¹⁰ m/s", "Qaliley", "Joule", "Çəkmə", "V/I", "8.8 m/s²", "Farad"),
          option_d = c("500 m/s", "3×10⁴ m/s", "Kepler", "Kalori", "İtələmə", "R/V", "12 m/s²", "Volt"),
          correct_answer = c("A", "A", "A", "C", "A", "A", "A", "A"),
          difficulty_level = c(1, 2, 1, 2, 1, 2, 1, 1),
          stringsAsFactors = FALSE
        )
      } else if(input$subject == "3") { # Kimya
        questions <- data.frame(
          id = 1:8,
          subject_id = 3,
          question_text = c(
            "Suyun kimyəvi düsturu nədir?",
            "Duz turşusunun düsturu = ?",
            "Oksigenin atom nömrəsi = ?",
            "pH = 7 nə deməkdir?",
            "Karbonun valensliyi = ?",
            "NaCl nədir?",
            "Qızılın kimyəvi simvolu = ?",
            "H₂SO₄ nədir?"
          ),
          option_a = c("H2O", "HCl", "8", "Neytral", "4", "Duz", "Au", "Sulfat turşu"),
          option_b = c("H2O2", "H2SO4", "6", "Turş", "2", "Şəkər", "Ag", "Duz turşusu"),
          option_c = c("HO2", "HNO3", "16", "Qələvi", "6", "Turşu", "Al", "Azot turşusu"),
          option_d = c("H3O", "CH3COOH", "12", "Dəyişkən", "8", "Maye", "Ar", "Sirkə turşusu"),
          correct_answer = c("A", "A", "A", "A", "A", "A", "A", "A"),
          difficulty_level = c(1, 1, 1, 2, 2, 1, 1, 1),
          stringsAsFactors = FALSE
        )
      } else { # Digər fənnlər üçün ümumi suallar
        questions <- data.frame(
          id = 1:5,
          subject_id = as.numeric(input$subject),
          question_text = c(
            "Bu fənn üzrə birinci sual",
            "Bu fənn üzrə ikinci sual", 
            "Bu fənn üzrə üçüncü sual",
            "Bu fənn üzrə dördüncü sual",
            "Bu fənn üzrə beşinci sual"
          ),
          option_a = c("Birinci cavab", "Birinci cavab", "Birinci cavab", "Birinci cavab", "Birinci cavab"),
          option_b = c("İkinci cavab", "İkinci cavab", "İkinci cavab", "İkinci cavab", "İkinci cavab"),
          option_c = c("Üçüncü cavab", "Üçüncü cavab", "Üçüncü cavab", "Üçüncü cavab", "Üçüncü cavab"),
          option_d = c("Dördüncü cavab", "Dördüncü cavab", "Dördüncü cavab", "Dördüncü cavab", "Dördüncü cavab"),
          correct_answer = c("A", "B", "C", "A", "B"),
          difficulty_level = c(1, 1, 1, 1, 1),
          stringsAsFactors = FALSE
        )
      }
      showNotification("PostgreSQL bağlantısı yoxdur, nümunə suallarla test davam edir", type = "warning")
    }
    
    # Test parametrlərini təyin et
    vals$questions <- questions
    vals$total_questions <- min(nrow(questions), input$num_questions)
    vals$questions <- questions[1:vals$total_questions, ]
    vals$answers <- rep(NA, vals$total_questions)
    vals$current_q <- 1
    vals$started <- TRUE
    vals$finished <- FALSE
    vals$paused <- FALSE
    vals$start_time <- Sys.time()
    vals$time_remaining <- vals$total_questions * 90  # hər sual üçün 90 saniyə
    vals$score <- 0
    
    showNotification("Test başladı! Uğurlar diləyirik!", type = "message")
    
    # İlk sualın cavablarını yenilə
    update_question_choices()
  })
  
  # Sual seçimlərini yenilə funksiyası
  update_question_choices <- function() {
    if(vals$started && !vals$finished && vals$current_q <= vals$total_questions) {
      q <- vals$questions[vals$current_q, ]
      
      new_choices <- setNames(
        c("A", "B", "C", "D"),
        c(paste("A.", q$option_a),
          paste("B.", q$option_b), 
          paste("C.", q$option_c),
          paste("D.", q$option_d))
      )
      
      selected_val <- if(!is.na(vals$answers[vals$current_q])) {
        vals$answers[vals$current_q]
      } else {
        character(0)
      }
      
      updateRadioButtons(session, "answer", 
                         choices = new_choices,
                         selected = selected_val)
    }
  }
  
  # Timer
  timer <- reactiveTimer(1000)
  
  observe({
    if(vals$started && !vals$finished && !vals$paused) {
      timer()
      isolate({
        vals$time_remaining <- vals$time_remaining - 1
        
        if(vals$time_remaining <= 0) {
          finish_test()
          showNotification("Vaxt bitdi! Test avtomatik olaraq tamamlandı.", type = "warning")
        }
      })
    }
  })
  
  # Ekran kontrolları
  output$test_started <- reactive({ vals$started && !vals$finished })
  output$test_finished <- reactive({ vals$finished })
  output$show_timer <- reactive({ vals$started && !vals$finished })
  
  outputOptions(output, "test_started", suspendWhenHidden = FALSE)
  outputOptions(output, "test_finished", suspendWhenHidden = FALSE)
  outputOptions(output, "show_timer", suspendWhenHidden = FALSE)
  
  # Timer göstər
  output$timer_display <- renderText({
    if(vals$started && !vals$finished) {
      minutes <- floor(vals$time_remaining / 60)
      seconds <- vals$time_remaining %% 60
      sprintf("%02d:%02d", minutes, seconds)
    }
  })
  
  # Sual məlumatları
  output$question_title <- renderText({
    if(vals$started) {
      paste("Sual", vals$current_q, "/", vals$total_questions)
    }
  })
  
  output$question_text <- renderText({
    if(vals$started && vals$current_q <= nrow(vals$questions)) {
      vals$questions$question_text[vals$current_q]
    }
  })
  
  output$subject_info <- renderText({
    if(vals$started) {
      subject_names <- c("1" = "Riyaziyyat", "2" = "Fizika", "3" = "Kimya", 
                         "4" = "Biologiya", "5" = "Tarix", "6" = "Coğrafiya",
                         "7" = "Ədəbiyyat", "8" = "İngilis dili", "9" = "İnformatika", "10" = "Fəlsəfə")
      subject_name <- subject_names[input$subject]
      paste("Fənn:", subject_name)
    }
  })
  
  # Proqres
  output$progress_text <- renderText({
    if(vals$started) {
      completed <- sum(!is.na(vals$answers))
      paste("Tamamlandı:", completed, "/", vals$total_questions)
    }
  })
  
  # Sual dəyişikliyi zamanı seçimləri yenilə
  observeEvent(vals$current_q, {
    update_question_choices()
  })
  
  # Cavabı saxla
  observeEvent(input$answer, {
    if(vals$started && !vals$finished) {
      vals$answers[vals$current_q] <- input$answer
    }
  })
  
  # Naviqasiya
  observeEvent(input$next_btn, {
    if(vals$current_q < vals$total_questions) {
      vals$current_q <- vals$current_q + 1
    }
  })
  
  observeEvent(input$prev, {
    if(vals$current_q > 1) {
      vals$current_q <- vals$current_q - 1
    }
  })
  
  # Pauza
  observeEvent(input$pause, {
    vals$paused <- !vals$paused
    if(vals$paused) {
      updateActionButton(session, "pause", "Davam")
      showNotification("Test pauzaya alındı", type = "message")
    } else {
      updateActionButton(session, "pause", "Pauza") 
      showNotification("Test davam edir", type = "message")
    }
  })
  
  # Cavabları göstər
  output$answers_display <- renderText({
    if(vals$started) {
      answered <- ifelse(is.na(vals$answers), "—", vals$answers)
      result <- ""
      for(i in 1:vals$total_questions) {
        status <- if(i == vals$current_q) ">" else " "
        result <- paste0(result, sprintf("%s %2d: %s\n", status, i, answered[i]))
      }
      return(result)
    }
  })
  
  # Test bitirmə funksiyası
  finish_test <- function() {
    # Balı hesabla
    correct_answers <- vals$questions$correct_answer
    vals$score <- sum(vals$answers == correct_answers, na.rm = TRUE)
    
    # Test nəticəsini hazırla və saxla
    duration_seconds <- as.numeric(difftime(Sys.time(), vals$start_time, units = "secs"))
    percentage <- round((vals$score / vals$total_questions) * 100, 1)
    
    # Cavabları JSON formatında hazırla
    answers_json <- jsonlite::toJSON(vals$answers, auto_unbox = FALSE)
    
    result_data <- data.frame(
      student_name = input$name,
      class_level = as.numeric(input$class),
      school_id = as.numeric(input$school),
      subject_id = as.numeric(input$subject),
      computer_number = input$computer,
      total_questions = vals$total_questions,
      correct_answers = vals$score,
      percentage = percentage,
      duration_seconds = round(duration_seconds),
      answers = answers_json,
      stringsAsFactors = FALSE
    )
    
    # Verilənlər bazasına saxla
    save_success <- save_test_result(result_data)
    
    if(save_success) {
      showNotification("Nəticəniz uğurla saxlanıldı!", type = "message")
    } else {
      showNotification("Nəticə saxlanmadı (PostgreSQL bağlantısı yoxdur), amma test bitdi.", type = "warning")
    }
    
    vals$finished <- TRUE
  }
  
  # Test bitir düyməsi
  observeEvent(input$finish, {
    finish_test()
  })
  
  # Final nəticələr
  output$final_score <- renderText({
    if(vals$finished) {
      paste("Doğru cavab:", vals$score, "/", vals$total_questions)
    }
  })
  
  output$final_percentage <- renderText({
    if(vals$finished) {
      percentage <- round((vals$score / vals$total_questions) * 100, 1)
      grade <- if(percentage >= 90) "Əla" 
      else if(percentage >= 80) "Yaxşı" 
      else if(percentage >= 70) "Orta" 
      else if(percentage >= 60) "Kafi" 
      else "Təkrarla"
      paste("Nəticə:", percentage, "% -", grade)
    }
  })
  
  # Nəticə təfərrüatları
  output$result_details <- DT::renderDataTable({
    if(vals$finished) {
      details <- data.frame(
        "№" = 1:vals$total_questions,
        "Sual" = substr(vals$questions$question_text, 1, 50),
        "Sizin cavab" = ifelse(is.na(vals$answers), "Boş", vals$answers),
        "Doğru cavab" = vals$questions$correct_answer,
        "Nəticə" = ifelse(vals$answers == vals$questions$correct_answer, "✓", "✗"),
        "Çətinlik" = vals$questions$difficulty_level,
        stringsAsFactors = FALSE,
        check.names = FALSE
      )
      
      DT::datatable(details, 
                    options = list(pageLength = 10, scrollX = TRUE, dom = 'tip'),
                    rownames = FALSE) %>%
        DT::formatStyle("Nəticə", 
                        backgroundColor = DT::styleEqual("✓", "#d4edda"))
    }
  })
  
  # Yenidən başla
  observeEvent(input$restart, {
    vals$started <- FALSE
    vals$finished <- FALSE
    vals$paused <- FALSE
    vals$current_q <- 1
    vals$answers <- c()
    vals$questions <- data.frame()
    vals$score <- 0
    vals$time_remaining <- 1800
    
    updateTextInput(session, "name", value = "")
    updateSelectInput(session, "class", selected = "")
    updateSelectInput(session, "school", selected = "")
    updateSelectInput(session, "subject", selected = "")
    updateNumericInput(session, "num_questions", value = 10)
    updateNumericInput(session, "computer", value = 1)
    updateActionButton(session, "pause", "Pauza")
    
    showNotification("Sistem sıfırlandı. Yeni test üçün hazırsınız!", type = "message")
  })
  
  # Nəticələr cədvəli
  output$all_results <- DT::renderDataTable({
    con <- get_db_connection()
    if(is.null(con)) {
      return(DT::datatable(
        data.frame("Məlumat" = "PostgreSQL bağlantısı yoxdur - Nəticələr göstərilə bilmir"),
        options = list(dom = "t"),
        rownames = FALSE
      ))
    }
    
    tryCatch({
      query <- "
        SELECT 
          tr.student_name as \"Şagird\",
          tr.class_level as \"Sinif\",
          s.school_name as \"Məktəb\",
          sub.subject_name as \"Fənn\",
          tr.correct_answers as \"Doğru\",
          tr.total_questions as \"Ümumi\",
          tr.percentage as \"Faiz (%)\",
          ROUND(tr.duration_seconds/60.0, 1) as \"Müddət (dəq)\",
          DATE(tr.test_date) as \"Tarix\"
        FROM test_results tr
        LEFT JOIN schools s ON tr.school_id = s.id
        LEFT JOIN subjects sub ON tr.subject_id = sub.id
        ORDER BY tr.test_date DESC
        LIMIT 100
      "
      
      results <- dbGetQuery(con, query)
      dbDisconnect(con)
      
      if(nrow(results) == 0) {
        return(DT::datatable(
          data.frame("Məlumat" = "Hələ heç bir test nəticəsi yoxdur"),
          options = list(dom = "t"),
          rownames = FALSE
        ))
      }
      
      DT::datatable(results, 
                    options = list(pageLength = 15, scrollX = TRUE),
                    rownames = FALSE) %>%
        DT::formatStyle("Faiz (%)", 
                        backgroundColor = DT::styleInterval(c(60, 80, 90), 
                                                            c("#f8d7da", "#fff3cd", "#d1ecf1", "#d4edda")))
    }, error = function(e) {
      if(!is.null(con)) dbDisconnect(con)
      return(DT::datatable(
        data.frame("Xəta" = paste("Məlumat alınarken xəta:", e$message)),
        options = list(dom = "t"),
        rownames = FALSE
      ))
    })
  })
  
  # Fənn statistikası
  output$subject_stats <- renderPlot({
    con <- get_db_connection()
    if(is.null(con)) {
      plot.new()
      text(0.5, 0.5, "PostgreSQL bağlantısı yoxdur\nStatistika göstərilə bilmir", 
           cex = 1.2, col = "red")
      return()
    }
    
    tryCatch({
      query <- "
        SELECT 
          sub.subject_name,
          COUNT(*) as test_count,
          AVG(tr.percentage) as avg_score
        FROM test_results tr
        LEFT JOIN subjects sub ON tr.subject_id = sub.id
        WHERE sub.subject_name IS NOT NULL
        GROUP BY sub.subject_name, sub.id
        ORDER BY avg_score DESC
      "
      
      stats <- dbGetQuery(con, query)
      dbDisconnect(con)
      
      if(nrow(stats) == 0) {
        plot.new()
        text(0.5, 0.5, "Statistika üçün məlumat yoxdur\n(Ən azı bir test tamamlanmalıdır)", 
             cex = 1.2, col = "gray50")
        return()
      }
      
      par(mar = c(8, 4, 4, 2), las = 2)
      barplot(stats$avg_score, 
              names.arg = stats$subject_name,
              main = "Fənn üzrə Orta Nəticələr",
              ylab = "Orta bal (%)",
              col = rainbow(nrow(stats)),
              ylim = c(0, 100))
      abline(h = c(60, 80, 90), col = "red", lty = 2, alpha = 0.5)
    }, error = function(e) {
      if(!is.null(con)) {
        tryCatch(dbDisconnect(con), error = function(e2) {})
      }
      plot.new()
      text(0.5, 0.5, "Statistika xətası", cex = 1.5, col = "red")
    })
  })
  
  # Məktəb reytinqi
  output$school_ranking <- renderPlot({
    con <- get_db_connection()
    if(is.null(con)) {
      plot.new()
      text(0.5, 0.5, "PostgreSQL bağlantısı yoxdur\nReytinq göstərilə bilmir", 
           cex = 1.2, col = "red")
      return()
    }
    
    tryCatch({
      query <- "
        SELECT 
          s.school_name,
          COUNT(*) as test_count,
          AVG(tr.percentage) as avg_score
        FROM test_results tr
        LEFT JOIN schools s ON tr.school_id = s.id
        WHERE s.school_name IS NOT NULL
        GROUP BY s.school_name, s.id
        HAVING COUNT(*) >= 3
        ORDER BY avg_score DESC
        LIMIT 10
      "
      
      ranking <- dbGetQuery(con, query)
      dbDisconnect(con)
      
      if(nrow(ranking) == 0) {
        plot.new()
        text(0.5, 0.5, "Reytinq məlumatları yoxdur\n(Ən azı 3 test olmalıdır)", 
             cex = 1.2, col = "gray50")
        return()
      }
      
      par(mar = c(12, 4, 4, 2), las = 2)
      barplot(ranking$avg_score,
              names.arg = substr(ranking$school_name, 1, 15),
              main = "Məktəblər üzrə Orta Nəticələr (ən azı 3 test)",
              ylab = "Orta bal (%)",
              col = heat.colors(nrow(ranking)),
              ylim = c(0, 100))
      abline(h = 75, col = "blue", lty = 2)
    }, error = function(e) {
      if(!is.null(con)) {
        tryCatch(dbDisconnect(con), error = function(e2) {})
      }
      plot.new()
      text(0.5, 0.5, "Reytinq xətası", cex = 1.5, col = "red")
    })
  })
}

# Tətbiqi işə sal
shinyApp(ui = ui, server = server)
