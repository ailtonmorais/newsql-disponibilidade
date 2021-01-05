CREATE TABLE categories (
    category_id int(11) NOT NULL PRIMARY KEY,
    category_name varchar(15) NOT NULL,
    description text,
    picture blob
) ENGINE=NDBCLUSTER;

CREATE TABLE customer_demographics (
    customer_type_id char NOT NULL PRIMARY KEY,
    customer_desc text
) ENGINE=NDBCLUSTER;

CREATE TABLE customers (
    customer_id char NOT NULL PRIMARY KEY,
    company_name varchar(40) NOT NULL,
    contact_name varchar(30),
    contact_title varchar(30),
    address varchar(60),
    city varchar(15),
    region varchar(15),
    postal_code varchar(10),
    country varchar(15),
    phone varchar(24),
    fax varchar(24)
) ENGINE=NDBCLUSTER;

CREATE TABLE customer_customer_demo (
    customer_id char NOT NULL,
    customer_type_id char NOT NULL,
    PRIMARY KEY (customer_id, customer_type_id),
    FOREIGN KEY (customer_type_id) REFERENCES customer_demographics(customer_type_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=NDBCLUSTER;

CREATE TABLE employees (
    employee_id int(11) NOT NULL PRIMARY KEY,
    last_name varchar(20) NOT NULL,
    first_name varchar(10) NOT NULL,
    title varchar(30),
    title_of_courtesy varchar(25),
    birth_date date,
    hire_date date,
    address varchar(60),
    city varchar(15),
    region varchar(15),
    postal_code varchar(10),
    country varchar(15),
    home_phone varchar(24),
    extension varchar(4),
    photo blob,
    notes text,
    reports_to int(11),
    photo_path varchar(255)	
) ENGINE=NDBCLUSTER;

CREATE TABLE suppliers (
    supplier_id int(11) NOT NULL PRIMARY KEY,
    company_name varchar(40) NOT NULL,
    contact_name varchar(30),
    contact_title varchar(30),
    address varchar(60),
    city varchar(15),
    region varchar(15),
    postal_code varchar(10),
    country varchar(15),
    phone varchar(24),
    fax varchar(24),
    homepage text
) ENGINE=NDBCLUSTER;

CREATE TABLE products (
    product_id int(11) NOT NULL PRIMARY KEY,
    product_name varchar(40) NOT NULL,
    supplier_id int(11),
    category_id int(11),
    quantity_per_unit varchar(20),
    unit_price double,
    units_in_stock int(11),
    units_on_order int(11),
    reorder_level int(11),
    discontinued integer NOT NULL,
	FOREIGN KEY (category_id) REFERENCES categories(category_id),
	FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
) ENGINE=NDBCLUSTER;

CREATE TABLE region (
    region_id int(11) NOT NULL PRIMARY KEY,
    region_description char NOT NULL
) ENGINE=NDBCLUSTER;

CREATE TABLE shippers (
    shipper_id int(11) NOT NULL PRIMARY KEY,
    company_name varchar(40) NOT NULL,
    phone varchar(24)
) ENGINE=NDBCLUSTER;

CREATE TABLE orders (
    order_id int(11) NOT NULL PRIMARY KEY,
    customer_id char,
    employee_id int(11),
    order_date date,
    required_date date,
    shipped_date date,
    ship_via int(11),
    freight double,
    ship_name varchar(40),
    ship_address varchar(60),
    ship_city varchar(15),
    ship_region varchar(15),
    ship_postal_code varchar(10),
    ship_country varchar(15),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)    
) ENGINE=NDBCLUSTER;

CREATE TABLE territories (
    territory_id varchar(20) NOT NULL PRIMARY KEY,
    territory_description char NOT NULL,
    region_id int(11) NOT NULL,
	FOREIGN KEY (region_id) REFERENCES region(region_id)
) ENGINE=NDBCLUSTER;

CREATE TABLE employee_territories (
    employee_id int(11) NOT NULL,
    territory_id varchar(20) NOT NULL,
    PRIMARY KEY (employee_id, territory_id),
    FOREIGN KEY (territory_id) REFERENCES territories(territory_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
) ENGINE=NDBCLUSTER;

CREATE TABLE order_details (
    order_id int(11) NOT NULL,
    product_id int(11) NOT NULL,
    unit_price double NOT NULL,
    quantity int(11) NOT NULL,
    discount double NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
) ENGINE=NDBCLUSTER;

CREATE TABLE us_states (
    state_id int(11) NOT NULL PRIMARY KEY,
    state_name varchar(100),
    state_abbr varchar(2),
    state_region varchar(50)
) ENGINE=NDBCLUSTER;
