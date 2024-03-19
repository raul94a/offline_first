

CREATE TABLE sync (
    id INTEGER AUTOINCREMENT,
    endpoint TEXT,
    body BLOB,
    headers BLOB,
    method varchar(255),
    strategy TEXT,
    constraint pk_sync PRIMARY KEY (id)
    
);