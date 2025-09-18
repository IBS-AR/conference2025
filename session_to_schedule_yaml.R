schedule <- readRDS("book/data/sessions.rds") |> select(first, last, org, coauthors, title, abstract, type, orgc, name2, org2, orgc2, day, order, room)
total_list <- list()
for (day_num in 2:5) {
  today <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday")[day_num]
  today_list <- list()

  for (order_num in as.character(0:max(schedule$order))) {

    for (room_num in c("A", "B")) {
      room_dat <- filter(schedule, day == day_num, order == order_num, room == room_num)

      if (nrow(room_dat) == 0) next

      all_titles <- map(1:nrow(room_dat), \(i) room_dat[i, ]$title)
      all_abstracts <- map(1:nrow(room_dat), \(i) room_dat[i, ]$abstract)
      all_names <- map(1:nrow(room_dat), \(i) paste(room_dat[i, ]$first, room_dat[i, ]$last))
      all_coauthors <- map(1:nrow(room_dat), \(i) room_dat[i, ]$coauthors)
      all_orgs <- map(1:nrow(room_dat), \(i) room_dat[i, ]$org)
      all_orgcs <- map(1:nrow(room_dat), \(i) room_dat[i, ]$orgc)
      all_name2s <- map(1:nrow(room_dat), \(i) room_dat[i, ]$name2)
      all_org2s <- map(1:nrow(room_dat), \(i) room_dat[i, ]$org2)
      all_orgc2s <- map(1:nrow(room_dat), \(i) room_dat[i, ]$orgc2)

      session_list <- list()
      for (i in 1:length(all_names)) {
        session_list[[glue::glue("talk_{i}")]] <- all_titles[[i]]
        if (length(all_name2s[[i]]) == 0 || is.na(all_name2s[[i]])) {
          if (length(all_coauthors[[i]]) == 0 || is.na(all_coauthors[[i]])) {
            session_list[[glue::glue("talk_{i}_speakers")]] <- glue::glue("{all_names[[i]]} 👤")
          } else {
            session_list[[glue::glue("talk_{i}_speakers")]] <- c(glue::glue("{all_names[[i]]} 👤"), unlist(strsplit(all_coauthors[[i]] , "\\s*(,|\\band\\b)\\s*")))
          }
        } else {
          if (length(all_coauthors[[i]]) == 0 || is.na(all_coauthors[[i]])) {
            session_list[[glue::glue("talk_{i}_speakers")]] <- c(glue::glue("{all_names[[i]]} 👤"), glue::glue("{all_name2s[[i]]} 👤"))
          } else {
            session_list[[glue::glue("talk_{i}_speakers")]] <- c(glue::glue("{all_names[[i]]} 👤"), glue::glue("{all_name2s[[i]]} 👤"), unlist(strsplit(all_coauthors[[i]] , "\\s*(,|\\band\\b)\\s*")))
          }

        }

        session_list[[glue::glue("talk_{i}_orgs")]] <- all_orgs[[i]]
        session_list[[glue::glue("talk_{i}_abstract")]] <- all_abstracts[[i]]
      }

      today_list[[glue::glue("{order_num}{room_num}")]] <- session_list

    }

  }

  total_list[[today]] <- today_list
}

yaml::write_yaml(total_list, "schedule_talks_only.yaml", line.sep = "\n")
