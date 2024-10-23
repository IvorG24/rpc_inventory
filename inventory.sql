DROP SCHEMA IF EXISTS inventory_schema CASCADE;
DROP SCHEMA IF EXISTS inventory_request_schema CASCADE;
DROP SCHEMA IF EXISTS event_schema CASCADE;
CREATE SCHEMA inventory_schema AUTHORIZATION postgres;
CREATE SCHEMA inventory_request_schema AUTHORIZATION postgres
CREATE SCHEMA event_schema AUTHORIZATION postgres

CREATE TABLE inventory_schema.inventory_form_table (
  form_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  form_name VARCHAR(4000) NOT NULL,
  form_description VARCHAR(4000) NOT NULL,
  form_date_created TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  form_is_disabled BOOLEAN DEFAULT FALSE NOT NULL,

  form_team_member_id UUID REFERENCES team_schema.team_member_table(team_member_id) NOT NULL
);

CREATE TABLE inventory_schema.section_table (
  section_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  section_name VARCHAR(4000) NOT NULL,
  section_order INT NOT NULL,
  section_is_duplicatable BOOLEAN DEFAULT FALSE NOT NULL,

  section_form_id UUID REFERENCES inventory_schema.inventory_form_table(form_id) NOT NULL
);

CREATE TABLE inventory_schema.field_table (
  field_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  field_name VARCHAR(4000) NOT NULL,
  field_is_required BOOLEAN DEFAULT FALSE NOT NULL,
  field_type VARCHAR(4000) NOT NULL,
  field_order INT NOT NULL,
  field_is_custom_field BOOLEAN DEFAULT FALSE NOT NULL,
  field_is_sub_category BOOLEAN DEFAULT FALSE NOT NULL,
  field_is_disabled BOOLEAN DEFAULT FALSE NOT NULL,
  field_is_read_only BOOLEAN DEFAULT FALSE NOT NULL,

  field_section_id UUID REFERENCES inventory_schema.section_table(section_id) NOT NULL
);

CREATE TABLE inventory_schema.option_table (
  option_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  option_value VARCHAR(4000) NOT NULL,
  option_order INT NOT NULL,

  option_field_id UUID REFERENCES inventory_schema.field_table(field_id) NOT NULL
);

CREATE TABLE inventory_schema.category_table (
  category_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  category_name VARCHAR(4000) NOT NULL,
  category_is_disabled BOOLEAN DEFAULT FALSE,

  category_team_id UUID REFERENCES team_schema.team_table(team_id) NOT NULL
);

CREATE TABLE inventory_schema.inventory_event_table (
  event_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  event_date_created TIMESTAMPTZ DEFAULT NOW() NOT NULl,
  event_name VARCHAR(4000) NOT NULL,
  event_status VARCHAR(4000) NOT NULL,
  event_color VARCHAR(4000) NOT NULL,
  event_description VARCHAR(4000) NOT NULL,
  event_is_disabled BOOLEAN DEFAULT FALSE NOT NULL,
  event_date_updated TIMESTAMPTZ,
  event_created_by UUID REFERENCES team_schema.team_member_table(team_member_id) NOT NULL,
  event_team_id UUID REFERENCES team_schema.team_table(team_id) NOT NULL
);

CREATE TABLE inventory_schema.customer_table (
  customer_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  customer_name TIMESTAMPTZ DEFAULT NOW() NOT NULl,
  customer_company VARCHAR(4000) NOT NULL,
  customer_email VARCHAR(4000) NOT NULL,
  customer_team_id UUID REFERENCES team_schema.team_table(team_id) NOT NULL
);

CREATE TABLE inventory_schema.event_form_connection_table (
  event_form_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  event_form_event_id UUID REFERENCES inventory_schema.inventory_event_table(event_id) NOT NULL,
  event_form_form_id UUID REFERENCES inventory_schema.inventory_form_table(form_id) NOT NULL,

  UNIQUE (event_form_event_id, event_form_form_id)
);

CREATE TABLE inventory_schema.site_table (
  site_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  site_name VARCHAR(4000) NOT NULL,
  site_description VARCHAR(4000) NOT NULL,
  site_is_disabled BOOLEAN DEFAULT FALSE NOT NULL,

  site_team_id UUID REFERENCES team_schema.team_table(team_id) NOT NULL
);

CREATE TABLE inventory_schema.location_table (
  location_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  location_name VARCHAR(4000) NOT NULL,
  location_is_disabled BOOLEAN DEFAULT FALSE NOT NULL,

  location_site_id UUID REFERENCES inventory_schema.site_table(site_id) NOT NULL
);

CREATE TABLE inventory_schema.inventory_permissions_table(
  inventory_permission_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  inventory_permission_key VARCHAR(255) UNIQUE NOT NULL,
  inventory_permission_label VARCHAR(255) NOT NULL
);

CREATE TABLE inventory_schema.inventory_group_permissions_table(
  inventory_group_permission_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  inventory_group_id UUID REFERENCES team_schema.team_group_table(team_group_id)NOT NULL,
  inventory_permission_id UUID REFERENCES inventory_schema.inventory_permissions_table(inventory_permission_id)NOT NULL,
  inventory_value BOOLEAN NOT NULL
);

CREATE TABLE inventory_schema.inventory_group_filter_table (
  inventory_group_ilter_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  inventory_group_id UUID REFERENCES team_schema.team_group_table(team_group_id)NOT NULL,
  inventory_group_filter_type VARCHAR(255) NOT NULL,
  inventory_group_filter_value_id UUID NOT NULL
);

CREATE TABLE inventory_schema.custom_field_table (
  custom_field_id UUID REFERENCES inventory_schema.field_table(field_id),
  category_id UUID REFERENCES inventory_schema.category_table(category_id),
  PRIMARY KEY (custom_field_id, category_id)
);

CREATE TABLE inventory_schema.sub_category_table (
  sub_category_id UUID REFERENCES inventory_schema.category_table(category_id),
  sub_field_id UUID REFERENCES inventory_schema.field_table(field_id),
  PRIMARY KEY (sub_category_id, sub_field_id)
);

CREATE TABLE inventory_request_schema.inventory_request_table(
   inventory_request_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
   inventory_request_tag_id INT NOT NULL,
   inventory_request_name VARCHAR(4000) NOT NULL,
   inventory_request_status VARCHAR(4000) DEFAULT 'AVAILABLE' NOT NULL,
   inventory_request_created TIMESTAMPTZ DEFAULT NOW() NOT NULL,
   inventory_request_date_updated TIMESTAMPTZ DEFAULT NOW() NOT NULL,
   inventory_request_csi_code VARCHAR(4000) NOT NULL,
   inventory_request_description VARCHAR (4000) NOT NULL,
   inventory_request_brand VARCHAR(4000) NOT NULL,
   inventory_request_model VARCHAR(4000) NOT NULL,
   inventory_request_serial_number VARCHAR(4000) NOT NULL,
   inventory_request_equipment_type VARCHAR(4000) NOT NULL,
   inventory_request_old_asset_number VARCHAR(4000),
   inventory_request_category VARCHAR(4000) NOT NULL,
   inventory_request_site VARCHAR(4000) NOT NULL,
   inventory_request_location VARCHAR(4000) NOT NULL,
   inventory_request_department VARCHAR(4000) NOT NULL,
   inventory_request_purchase_order VARCHAR(4000) NOT NULL,
   inventory_request_purchase_from VARCHAR(4000) NOT NULL,
   inventory_request_purchase_date VARCHAR(4000) NOT NULL,
   inventory_request_purchase_from VARCHAR(4000) NOT NULL,
   inventory_request_cost VARCHAR(4000) NOT NULL,
   inventory_request_si_number VARCHAR(4000) NOT NULL,
   inventory_request_due_date VARCHAR(4000),

   inventory_request_created_by UUID REFERENCES team_schema.team_member_table(team_member_id) NOT NULL,
   inventory_request_form_id UUID REFERENCES inventory_schema.inventory_form_table(form_id) NOT NULL
);

CREATE TABLE inventory_request_schema.inventory_relationship_table (
  parent_asset_id UUID NOT NULL REFERENCES inventory_request_schema.inventory_request_table(inventory_request_id) ON DELETE CASCADE,
  child_asset_id UUID NOT NULL REFERENCES inventory_request_schema.inventory_request_table(inventory_request_id) ON DELETE CASCADE,
  PRIMARY KEY (parent_asset_id, child_asset_id)
);

CREATE TABLE inventory_request_schema.inventory_custom_response_table(
  inventory_response_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  inventory_response_value VARCHAR(4000) NOT NULL,
  inventory_response_field_id UUID REFERENCES inventory_schema.field_table(field_id),
  inventory_response_asset_request_id UUID REFERENCES inventory_request_schema.inventory_request_table(inventory_request_id) NOT NULL
);

CREATE TABLE inventory_request_schema.inventory_assignee_table(
  inventory_assignee_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  inventory_assignee_team_member_id UUID REFERENCES team_schema.team_member_table(team_member_id),
  inventory_assignee_customer_id UUID REFERENCES inventory_schema.customer_table(customer_id),
  inventory_assignee_site_id UUID REFERENCES inventory_schema.site_table(site_id),
  inventory_assignee_asset_request_id UUID REFERENCES inventory_request_schema.inventory_request_table(inventory_request_id) NOT NULL
);

CREATE TABLE inventory_request_schema.inventory_history_table(
  inventory_history_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  inventory_history_date_created TIMESTAMPTZ DEFAULT NOW(),
  inventory_history_event VARCHAR(4000) NOT NULL,
  inventory_history_changed_to VARCHAR(4000),
  inventory_history_changed_from VARCHAR(4000),
  inventory_history_assigneed_to VARCHAR(4000),
  inventory_history_returned_to VARCHAR(4000),

  inventory_history_request_id UUID REFERENCES inventory_request_schema.inventory_request_table(inventory_request_id) NOT NULL,
  inventory_history_action_by UUID REFERENCES team_schema.team_member_table(team_member_id) NOT NULL
);

CREATE TABLE inventory_request_schema.inventory_event_table(
  inventory_event_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
  inventory_event_date_created TIMESTAMPTZ DEFAULT NOW(),
  inventory_event VARCHAR(4000),
  inventory_event_check_out_date TIMESTAMPTZ,
  inventory_event_return_date TIMESTAMPTZ,
  inventory_event_due_date TIMESTAMPTZ,
  inventory_event_notes VARCHAR(4000),
  inventory_event_signature VARCHAR(4000) NOT NULL,

  inventory_event_request_id UUID REFERENCES inventory_request_schema.inventory_request_table(inventory_request_id) NOT NULL
);


CREATE TABLE event_schema.event_sell_table(
    event_sell_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    event_sell_sold_to VARCHAR(4000),
    event_sell_sold_value VARCHAR(4000)
);

CREATE TABLE event_schema.event_check_out_table(
    event_check_out_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    event_check_out_date_created TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    event_check_out_check_out_date TIMESTAMPTZ DEFAULT NOW(),
    event_check_out_assigned_to VARCHAR(4000),
    event_check_out_site VARCHAR(4000) NOT NULL,
    event_check_out_location VARCHAR(4000),
    event_check_out_department VARCHAR(4000)  NOT NULL,
    event_check_out_notes VARCHAR(4000),
    event_check_out_signature VARCHAR(4000) NOT NULL,
    event_check_out_request_id UUID REFERENCES inventory_request_schema.inventory_request_table(inventory_request_id) NOT NULL
);
CREATE TABLE event_schema.event_check_in_table(
    event_check_in_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    event_check_in_date_created TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    event_check_in_check_in_date TIMESTAMPTZ DEFAULT NOW(),
    event_check_in_site VARCHAR(4000) NOT NULL,
    event_check_in_location VARCHAR(4000),
    event_check_in_department VARCHAR(4000) NOT NULL,
    event_check_in_notes VARCHAR(4000),
    event_check_in_signature VARCHAR(4000) NOT NULL,
    event_check_in_request_id UUID REFERENCES inventory_request_schema.inventory_request_table(inventory_request_id) NOT NULL
);

CREATE TABLE event_schema.event_lost_table(
    event_lost_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    event_lost_date_created TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    event_lost_date_lost TIMESTAMPTZ DEFAULT NOW(),
    event_lost_signature VARCHAR(4000) NOT NULL,
    event_lost_notes VARCHAR(4000),
    event_lost_request_id UUID REFERENCES inventory_request_schema.inventory_request_table(inventory_request_id) NOT NULL
);

CREATE TABLE event_schema.event_broken_table(
    event_broken_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    event_broken_date_created TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    event_broken_date_broken TIMESTAMPTZ DEFAULT NOW(),
    event_broken_signature VARCHAR(4000) NOT NULL,
    event_broken_notes VARCHAR(4000),

    event_broken_request_id UUID REFERENCES inventory_request_schema.inventory_request_table(inventory_request_id) NOT NULL
);

CREATE TABLE event_schema.event_donate_table(
    event_donate_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    event_donate_date_created TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    event_donate_date_donated TIMESTAMPTZ DEFAULT NOW(),
    event_donate_donated_to VARCHAR(4000),
    event_donate_donate_value INT,
    event_donate_signature VARCHAR(4000) NOT NULL,
    event_donate_notes VARCHAR(4000),

    event_donate_request_id UUID REFERENCES inventory_request_schema.inventory_request_table(inventory_request_id) NOT NULL
);

CREATE TABLE event_schema.event_dispose_table(
    event_dispose_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    event_dispose_date_created TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    event_dispose_date_dispose TIMESTAMPTZ DEFAULT NOW(),
    event_dispose_signature VARCHAR(4000) NOT NULL,
    event_dispose_notes VARCHAR(4000),


    event_dispose_request_id UUID REFERENCES inventory_request_schema.inventory_request_table(inventory_request_id) NOT NULL
);

CREATE TABLE event_schema.event_found_table(
    event_found_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY NOT NULL,
    event_found_date_created TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    event_found_date_found TIMESTAMPTZ DEFAULT NOW(),
    event_found_signature VARCHAR(4000) NOT NULL,
    event_found_notes VARCHAR(4000),


    event_found_request_id UUID REFERENCES inventory_request_schema.inventory_request_table(inventory_request_id) NOT NULL
);




-- //department from team_schema

GRANT ALL ON ALL TABLES IN SCHEMA inventory_schema TO PUBLIC;
GRANT ALL ON ALL TABLES IN SCHEMA inventory_schema TO POSTGRES;
GRANT ALL ON SCHEMA inventory_schema TO postgres;
GRANT ALL ON SCHEMA inventory_schema TO public;


GRANT ALL ON ALL TABLES IN SCHEMA inventory_request_schema TO PUBLIC;
GRANT ALL ON ALL TABLES IN SCHEMA inventory_request_schema TO POSTGRES;
GRANT ALL ON SCHEMA inventory_request_schema TO postgres;
GRANT ALL ON SCHEMA inventory_request_schema TO public;

GRANT ALL ON ALL TABLES IN SCHEMA event_schema TO PUBLIC;
GRANT ALL ON ALL TABLES IN SCHEMA event_schema TO POSTGRES;
GRANT ALL ON SCHEMA event_schema TO postgres;
GRANT ALL ON SCHEMA event_schema TO public;


CREATE OR REPLACE FUNCTION create_inventory_request_page_on_load(
  input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
  let returnData;
  plv8.subtransaction(function() {
    const {
      formId,
      userId
    } = input_data;

    const teamId = plv8.execute(`SELECT public.get_user_active_team_id('${userId}')`)[0].get_user_active_team_id;
    if (!teamId) throw new Error("No team found");

    const teamMember = plv8.execute(`SELECT * FROM team_schema.team_member_table WHERE team_member_user_id = '${userId}' AND team_member_team_id = '${teamId}'`)[0];
    if (!teamMember) throw new Error("No team member found");

    const formData = plv8.execute(
      `
        SELECT
          form_id,
          form_name,
          form_description,
          form_date_created,
          team_member_id,
          user_id,
          user_first_name,
          user_last_name,
          user_avatar,
          user_username
        FROM inventory_schema.inventory_form_table
        INNER JOIN team_schema.team_member_table ON team_member_id = form_team_member_id
        INNER JOIN user_schema.user_table ON user_id = team_member_user_id
        WHERE form_id = '${formId}'
      `
    )[0];

    const sectionData = [];
    const formSection = plv8.execute(`SELECT * FROM inventory_schema.section_table WHERE section_form_id = '${formId}' ORDER BY section_order ASC`);

    formSection.forEach(section => {
      const fieldData = plv8.execute(
        `
          SELECT *
          FROM inventory_schema.field_table
          WHERE field_section_id = '${section.section_id}'
          AND field_is_custom_field = False
          AND field_is_sub_category = False
          AND field_is_disabled = False
          ORDER BY field_order ASC
        `
      );

      const fieldsWithOptions = fieldData.map(field => {
        let optionData = plv8.execute(`
          SELECT *
          FROM inventory_schema.option_table
          WHERE option_field_id = '${field.field_id}'
          ORDER BY option_order ASC
        `);

        if (field.field_name === "Department") {
          const departmentOptions = plv8.execute(`
            SELECT team_department_id, team_department_name
            FROM team_schema.team_department_table
          `).map((department, index) => ({
            option_field_id: field.field_id,
            option_id: department.team_department_id,
            option_order: optionData.length + index,
            option_value: department.team_department_name,
          }));
          optionData = optionData.concat(departmentOptions);
        } else if (field.field_name === "Category") {
          const categoryOptions = plv8.execute(`
            SELECT category_id, category_name
            FROM inventory_schema.category_table
            WHERE category_team_id = '${teamId}'
          `).map((category, index) => ({
            option_field_id: field.field_id,
            option_id: category.category_id,
            option_order: optionData.length + index,
            option_value: category.category_name,
          }));
          optionData = optionData.concat(categoryOptions);
        } else if (field.field_name === "Site") {
          const siteOptions = plv8.execute(`
            SELECT site_id, site_name
            FROM inventory_schema.site_table
            WHERE site_team_id = '${teamId}'
          `).map((site, index) => ({
            option_field_id: field.field_id,
            option_id: site.site_id,
            option_order: optionData.length + index,
            option_value: site.site_name,
          }));
          optionData = optionData.concat(siteOptions);
        }

        return {
          ...field,
          field_option: optionData
        };
      });

      sectionData.push({
        ...section,
        section_field: fieldsWithOptions,
      });
    });

    const form = {
      form_id: formData.form_id,
      form_name: formData.form_name,
      form_description: formData.form_description,
      form_date_created: formData.form_date_created,
      form_team_member: {
        team_member_id: formData.team_member_id,
        team_member_user: {
          user_id: formData.user_id,
          user_first_name: formData.user_first_name,
          user_last_name: formData.user_last_name,
          user_avatar: formData.user_avatar,
          user_username: formData.user_username
        }
      },
      form_section: sectionData,
    };

    returnData = {
      form
    };
  });

  return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION modal_form_on_load(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
  let returnData = {};
  plv8.subtransaction(function() {
    const { userId, eventId } = input_data;

    const formResult = plv8.execute(`
        SELECT event_form_form_id
        FROM inventory_schema.event_form_connection_table
        WHERE event_form_event_id = $1
    `, [eventId]);

    if (formResult.length > 0) {
        const formId = formResult[0].event_form_form_id;
        const payload = JSON.stringify({
            userId: userId,
            formId: formId[0].event_form_form_id
        });

        const formDataResult = plv8.execute(`
            SELECT public.create_inventory_request_page_on_load($1)
        `, [payload]);

        if (formDataResult.length > 0) {
            returnData = formDataResult[0];
        }
    }
  });

  return returnData;
$$ LANGUAGE plv8;


CREATE OR REPLACE FUNCTION create_asset(
  input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
  let asset_data;
  plv8.subtransaction(function(){
    const {
      requestId,
      formId,
      teamMemberId,
      asset_name,
      csi_code,
      description,
      brand,
      model,
      serial_number,
      equipment_type,
      category,
      old_asset_number,
      site,
      location,
      department,
      purchase_order,
      purchase_date,
      purchase_form,
      cost,
      si_number,
      responseValues
    } = input_data;
    let tagCount = 1
    const assetTagId = plv8.execute(`
        SELECT inventory_request_tag_id
        FROM inventory_request_schema.inventory_request_table
        ORDER BY inventory_request_created DESC
        LIMIT 1
    `)

    if(assetTagId.length > 0 ){
        tagCount = assetTagId[0].inventory_request_tag_id + 1
    };

    asset_data = plv8.execute(
      `
        INSERT INTO inventory_request_schema.inventory_request_table
        (
		  inventory_request_id,
          inventory_request_tag_id,
          inventory_request_name,
          inventory_request_csi_code,
          inventory_request_description,
          inventory_request_brand,
          inventory_request_model,
          inventory_request_serial_number,
          inventory_request_equipment_type,
          inventory_request_category,
          inventory_request_site,
          inventory_request_location,
          inventory_request_department,
          inventory_request_purchase_order,
          inventory_request_purchase_date,
          inventory_request_purchase_from,
          inventory_request_cost,
          inventory_request_si_number,
          inventory_request_form_id,
          inventory_request_created_by,
          inventory_request_old_asset_number
        )
        VALUES
        (
          $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21
        )
        RETURNING *
      `,
      [
        requestId,tagCount,asset_name, csi_code,description, brand, model, serial_number, equipment_type,
        category, site, location, department, purchase_order, purchase_date,
        purchase_form, cost, si_number, formId, teamMemberId, old_asset_number
      ]
    )[0];
    plv8.execute(`
     INSERT INTO inventory_request_schema.inventory_custom_response_table
        (inventory_response_value,inventory_response_field_id,inventory_response_asset_request_id)
        VALUES
        ${responseValues}
    `);

    const request_assignee = plv8.execute(
      `
        INSERT INTO inventory_request_schema.inventory_assignee_table
         (inventory_assignee_asset_request_id)
        VALUES
         ($1)
        RETURNING *
      `,
      [requestId]
    )[0];
  });
  return asset_data;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION inventory_request_page_on_load(
  input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
  let returnData;
  plv8.subtransaction(function() {
    const {
      assetId,
      userId
    } = input_data;

    const assetIdData = plv8.execute(`
        SELECT inventory_request_id
        FROM inventory_request_schema.inventory_request_table
        WHERE inventory_request_tag_id = '${assetId}'
    `)[0];

    const payload = JSON.stringify({
            userId: userId,
            formId: "656a3009-7127-4960-9738-92afc42779a6"
        });


    const formDataResult = plv8.execute(`
        SELECT public.create_inventory_request_page_on_load($1)
    `, [payload])[0].create_inventory_request_page_on_load.form;

    const assetInventoryData = plv8.execute(`
        SELECT *
        FROM inventory_request_schema.inventory_request_table
        WHERE inventory_request_id = $1
    `,[assetIdData.inventory_request_id])[0]


CREATE OR REPLACE FUNCTION inventory_request_page_on_load(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
    let returnData = null;
    plv8.subtransaction(function() {
        const { assetId, userId } = input_data;

        // Fetch the request ID based on assetId
        const assetIdData = plv8.execute(`
            SELECT inventory_request_id
            FROM inventory_request_schema.inventory_request_table
            WHERE inventory_request_tag_id = $1
        `, [assetId])[0];

        // Create payload for another function call
        const payload = JSON.stringify({
            userId: userId,
            formId: "656a3009-7127-4960-9738-92afc42779a6"
        });

        // Fetch form data from external function
        const formDataResult = plv8.execute(`
            SELECT public.create_inventory_request_page_on_load($1)
        `, [payload])[0].create_inventory_request_page_on_load.form;

        // Fetch asset inventory data
        const assetInventoryData = plv8.execute(`
            SELECT *
            FROM inventory_request_schema.inventory_request_table
            WHERE inventory_request_id = $1
        `, [assetIdData.inventory_request_id])[0];

        // Populate form fields
        const formData = {
            form: {
                ...formDataResult,
                form_section: [
                    {
                        ...formDataResult.form_section[0],
                        section_field: [
                            {
                                ...formDataResult.form_section[0].section_field[0],
                                field_response: assetInventoryData.inventory_request_name,
                                field_type:"TEXT",
								field_is_read_only:true
                            },
                            {
                                ...formDataResult.form_section[0].section_field[1],
                                field_response: assetInventoryData.inventory_request_csi_code
                            },
                            {
                                ...formDataResult.form_section[0].section_field[2],
                                field_response: assetInventoryData.inventory_request_description
                            },
                            {
                                ...formDataResult.form_section[0].section_field[3],
                                field_response: assetInventoryData.inventory_request_brand
                            },
                            {
                                ...formDataResult.form_section[0].section_field[4],
                                field_response: assetInventoryData.inventory_request_model
                            },
                            {
                                ...formDataResult.form_section[0].section_field[5],
                                field_response: assetInventoryData.inventory_request_serial_number
                            },
                            {
                                ...formDataResult.form_section[0].section_field[6],
                                field_response: assetInventoryData.inventory_request_equipment_type
                            },
                            {
                                ...formDataResult.form_section[0].section_field[7],
                                field_response: assetInventoryData.inventory_request_old_asset_number
                            }
                        ]
                    },
                    {
                        ...formDataResult.form_section[1],
                        section_field: [
                            {
                                ...formDataResult.form_section[1].section_field[0],
                                field_response: assetInventoryData.inventory_request_category
                            }
                        ]
                    },
                    {
                        ...formDataResult.form_section[2],
                        section_field: [
                            {
                                ...formDataResult.form_section[2].section_field[0],
                                field_response: assetInventoryData.inventory_request_site
                            },
                            {
                                ...formDataResult.form_section[2].section_field[1],
                                field_response: assetInventoryData.inventory_request_location
                            },
                            {
                                ...formDataResult.form_section[2].section_field[2],
                                field_response: assetInventoryData.inventory_request_department
                            }
                        ]
                    },
                    {
                        ...formDataResult.form_section[3],
                        section_field: [
                            {
                                ...formDataResult.form_section[3].section_field[0],
                                field_response: assetInventoryData.inventory_request_purchase_order
                            },
                            {
                                ...formDataResult.form_section[3].section_field[1],
                                field_response: assetInventoryData.inventory_request_purchase_date
                            },
                            {
                                ...formDataResult.form_section[3].section_field[2],
                                field_response: assetInventoryData.inventory_request_purchase_from
                            },
                            {
                                ...formDataResult.form_section[3].section_field[3],
                                field_response: parseInt(assetInventoryData.inventory_request_cost,10)
                            },
                            {
                                ...formDataResult.form_section[3].section_field[4],
                                field_response: assetInventoryData.inventory_request_si_number
                            }
                        ]
                    }
                ]
            }
        };
        returnData = formData;
    });
    return returnData;
$$ LANGUAGE plv8;


CREATE OR REPLACE FUNCTION get_sub_field_options(
  input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
  let returnData = {
    data:[],
    totalCount:0
  };

  plv8.subtransaction(function() {
    const { page, limit, search } = input_data;
    const currentPage = page || 1;
    const rowLimit = limit || 10;
    const offset = (currentPage - 1) * rowLimit;
    const searchQuery = search ? `AND category_id = '${search}'` : '';
    const searchSubQuery = search ? ` WHERE sub_category_id = '${search}'` : '';

    const countData = plv8.execute(
    `
        SELECT COUNT(*)
        FROM inventory_schema.sub_category_table
       ${searchSubQuery}
    `,
    );
    returnData.totalCount = String(countData[0].count);
    const subFieldData = plv8.execute(
      `
      SELECT sub_field_id
      FROM inventory_schema.sub_category_table
      LIMIT $1 OFFSET $2
      `, [rowLimit, offset]
    );

    subFieldData.forEach(subField => {
      const fieldData = plv8.execute(
        `
        SELECT field_id, field_name
        FROM inventory_schema.field_table
        WHERE field_id = $1 AND field_is_disabled = False
        `, [subField.sub_field_id,]
      );

      fieldData.forEach(field => {
        const subCategoryData = plv8.execute(
          `
          SELECT sub_category_id
          FROM inventory_schema.sub_category_table
          WHERE sub_field_id = $1
          `, [field.field_id]
        );

        subCategoryData.forEach(option => {
          const categoryData = plv8.execute(
            `
            SELECT category_id, category_name
            FROM inventory_schema.category_table
            WHERE category_id = $1
            ${searchQuery}
            `, [option.sub_category_id]
          );

          if (categoryData.length > 0) {
            returnData.data.push({
              sub_category_id: field.field_id,
              sub_category_name: field.field_name,
              category_id: categoryData[0].category_id,
              category_name: categoryData[0].category_name
            });
          }
        });
      });
    });
  });

  return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION update_asset(
  input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
  let asset_data;
  plv8.subtransaction(function(){
    const {
      assetId,
      formId,
      teamMemberId,
      asset_name,
      csi_code,
      description,
      brand,
      model,
      serial_number,
      equipment_type,
      category,
      old_asset_number,
      site,
      location,
      department,
      purchase_order,
      purchase_date,
      purchase_form,
      cost,
      si_number,
      responseValues
    } = input_data;


    asset_data = plv8.execute(
      `
        UPDATE inventory_request_schema.inventory_request_table
        SET
          inventory_request_name = $1,
          inventory_request_csi_code = $2,
          inventory_request_brand = $3,
          inventory_request_model = $4,
          inventory_request_serial_number = $5,
          inventory_request_equipment_type = $6,
          inventory_request_category = $7,
          inventory_request_site = $8,
          inventory_request_location = $9,
          inventory_request_department = $10,
          inventory_request_purchase_order = $11,
          inventory_request_purchase_date = $12,
          inventory_request_purchase_from = $13,
          inventory_request_cost = $14,
          inventory_request_si_number = $15,
          inventory_request_form_id = $16,
          inventory_request_created_by = $17,
          inventory_request_old_asset_number = $18,
          inventory_request_description = $19
        WHERE inventory_request_id = $20
        RETURNING *
      `,
      [
        asset_name, csi_code, brand, model, serial_number, equipment_type,
        category, site, location, department, purchase_order, purchase_date,
        purchase_form, cost, si_number, formId, teamMemberId, old_asset_number,description, assetId
      ]
    )[0];

    plv8.execute(`
        INSERT INTO inventory_request_schema.inventory_history_table (
            inventory_history_action_by,
            inventory_history_request_id,
            inventory_history_event
        )
        VALUES ($1, $2, $3)
    `, [teamMemberId, assetId, "UPDATE"]);


    plv8.execute(`
      DELETE FROM inventory_request_schema.inventory_custom_response_table
      WHERE inventory_response_asset_request_id = $1
    `, [assetId]);

     plv8.execute(`
      DELETE FROM inventory_request_schema.inventory_custom_response_table
      WHERE inventory_response_asset_request_id = $1
    `, [assetId]);

    if(responseValues.length > 0 ){
    plv8.execute(`
     INSERT INTO inventory_request_schema.inventory_custom_response_table
        (inventory_response_value,inventory_response_field_id,inventory_response_asset_request_id) VALUES ${responseValues}
    `);
    }
  });
  return asset_data;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION get_sub_or_custom_field(
  input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
  let returnData = {};
  plv8.subtransaction(function(){
    const { categoryName, assetId } = input_data;

    const categoryId = plv8.execute(`
        SELECT category_id
        FROM inventory_schema.category_table
        WHERE category_name = '${categoryName}'
    `)[0].category_id;

    let assetIdData = null;

    if (assetId) {
      assetIdData = plv8.execute(`
        SELECT inventory_request_id
        FROM inventory_request_schema.inventory_request_table
        WHERE inventory_request_tag_id = '${assetId}'
      `)[0];
    }

    const customFieldData = assetIdData
      ? plv8.execute(`
          SELECT f.*, (
            SELECT cr.inventory_response_value
            FROM inventory_request_schema.inventory_custom_response_table AS cr
            WHERE cr.inventory_response_field_id = f.field_id
            AND cr.inventory_response_asset_request_id = '${assetIdData.inventory_request_id}'
            LIMIT 1
          ) AS field_response
          FROM inventory_schema.custom_field_table AS c
          JOIN inventory_schema.field_table AS f
          ON f.field_id = c.custom_field_id
          WHERE c.category_id = '${categoryId}'
          AND f.field_is_disabled = False
        `)
      : plv8.execute(`
          SELECT f.*
          FROM inventory_schema.custom_field_table AS c
          JOIN inventory_schema.field_table AS f
          ON f.field_id = c.custom_field_id
          WHERE c.category_id = '${categoryId}'
          AND f.field_is_disabled = False
        `);

    const subFieldData = assetIdData
      ? plv8.execute(`
          SELECT f.*, (
            SELECT cr.inventory_response_value
            FROM inventory_request_schema.inventory_custom_response_table AS cr
            WHERE cr.inventory_response_field_id = f.field_id
            AND cr.inventory_response_asset_request_id = '${assetIdData.inventory_request_id}'
            LIMIT 1
          ) AS field_response
          FROM inventory_schema.sub_category_table AS s
          JOIN inventory_schema.field_table AS f
          ON f.field_id = s.sub_field_id
          WHERE s.sub_category_id = '${categoryId}'
          AND f.field_is_disabled = False
        `)
      : plv8.execute(`
          SELECT f.*
          FROM inventory_schema.sub_category_table AS s
          JOIN inventory_schema.field_table AS f
          ON f.field_id = s.sub_field_id
          WHERE s.sub_category_id = '${categoryId}'
          AND f.field_is_disabled = False
        `);

    returnData = {
      customFields: customFieldData,
      subFields: subFieldData
    };
  });
  return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION get_column_fields()
RETURNS JSON
SET search_path TO ''
AS $$

  let returnData = [];
  plv8.subtransaction(function(){
    const fields = plv8.execute(`
      SELECT *
      FROM inventory_schema.field_table
      WHERE field_section_id = '80aedd40-a682-4390-9e82-0e9592f7f912'
      AND (
        (field_is_custom_field = True OR field_is_sub_category = True)
      )
      AND field_is_disabled = False
    `);

    fields.forEach((field) => {
      returnData.push({
        value: field.field_name.toLowerCase().replace(/\s/g, '_'),
        label: field.field_name,
      });
    });
  });
  returnData.unshift(
    { label: "Asset Tag Id", value: "inventory_request_tag_id" },
    { label: "Asset Name", value: "inventory_request_name" },
    { label: "Status", value: "inventory_request_status" },
    { label: "Date Created", value: "inventory_request_created" },
    { label: "CSI Code", value: "inventory_request_csi_code" },
    { label: "Description", value: "inventory_request_description" },
    { label: "Brand", value: "inventory_request_brand" },
    { label: "Model", value: "inventory_request_model" },
    { label: "Old Asset Number", value: "inventory_request_old_asset_number" },
    { label: "IT Equipment Type", value: "inventory_request_equipment_type" },
    { label: "Serial No.", value: "inventory_request_serial_number" },
    { label: "Site", value: "inventory_request_site" },
    { label: "Location", value: "inventory_request_location" },
    { label: "Department", value: "inventory_request_department" },
    { label: "Notes", value: "inventory_request_notes" },
    { label: "Purchase Order", value: "inventory_request_purchase_order" },
    { label: "Purchase Date", value: "inventory_request_purchase_date" },
    { label: "Purchase From", value: "inventory_request_purchase_from" },
    { label: "Cost", value: "inventory_request_cost" },
    { label: "SI No.", value: "inventory_request_si_number" },
    { label: "Event Date", value: "inventory_event_date_created" }
  );

  return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION create_drawer_data(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
  let returnData = null;
  plv8.subtransaction(function(){
    const { InventoryFormValues, type, teamId } = input_data;

    if(type === "site"){
        const { site_name, site_description } = InventoryFormValues;

        const resultData = plv8.execute(`
            INSERT INTO inventory_schema.site_table (site_name, site_description, site_team_id)
            VALUES ($1, $2, $3)
            RETURNING site_id, site_name, site_description, site_team_id
        `, [site_name, site_description, teamId]);

        returnData = resultData.map((result) => {
            return {
                result_id: result.site_id,
                result_name: result.site_name,
                result_description: result.site_description,
                result_team_id: result.site_team_id
            };
        })[0];
    }else if (type === "location"){
        const { site_id, location_name } = InventoryFormValues;

        const resultData = plv8.execute(`
            INSERT INTO inventory_schema.location_table(location_name, location_site_id)
            VALUES ($1, $2)
            RETURNING location_id, location_name, location_site_id
        `, [location_name, site_id]);

        returnData = resultData.map((result) => {
            return {
                result_id: result.location_id,
                result_name: result.location_name,
                result_site_id:result.location_site_id
            };
        })[0];
    }else if (type === "category"){
        const { category_name } = InventoryFormValues;
        const resultData = plv8.execute(`
            INSERT INTO inventory_schema.category_table(category_name,category_team_id)
            VALUES ($1, $2)
            RETURNING category_id, category_name, category_team_id
        `, [category_name, teamId]);

           returnData = resultData.map((result) => {
            return {
                result_id: result.category_id,
                result_name: result.category_name,
            };
        })[0];
    }else if (type === "sub-category"){
        const { category_id, sub_category }= InventoryFormValues;
        const categoryName = plv8.execute(`
          SELECT category_name
          FROM inventory_schema.category_table
          WHERE category_id = $1
        `,[category_id])[0].category_name

        const resultData = plv8.execute(`
            INSERT INTO inventory_schema.field_table(field_name,field_type,field_order,field_is_sub_category,field_section_id)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING field_id, field_name
        `, [sub_category, "TEXT", 2, "TRUE", '80aedd40-a682-4390-9e82-0e9592f7f912']);

        const subCategoryConnection = plv8.execute(`
            INSERT INTO inventory_schema.sub_category_table(sub_category_id,sub_field_id)
            VALUES ($1, $2)
        `,[category_id, resultData[0].field_id])

       returnData = resultData.map((result) => {
            return {
                result_id: result.category_id,
                result_name: result.field_name,
                result_category_name:categoryName
            };
        })[0];
    }else if (type === "department"){
        const { department_name }= InventoryFormValues;
        const resultData = plv8.execute(`
            INSERT INTO team_schema.team_department_table(team_department_name)
            VALUES ($1)
            RETURNING team_department_id, team_department_name
        `, [department_name]);

       returnData = resultData.map((result) => {
            return {
                result_id: result.team_department_id,
                result_name: result.team_department_name,
            };
        })[0];
    }
  });
  return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION disable_drawer_data(
        input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
    let returnData = null;
    plv8.subtransaction(function(){
        const { typeId, type } = input_data;

        returnData = plv8.execute(`
                UPDATE inventory_schema.${type}_table
                SET ${type}_is_disabled = true
                WHERE ${type}_id = $1
                RETURNING *;
            `, [typeId]);
    })
    return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION check_unique_drawer_data(
    input_data JSON
)
RETURNS BOOLEAN
SET search_path TO ''
AS $$
    let returnData = false;
    plv8.subtransaction(function(){
        const { type, typeValue } = input_data;
        const lowerTypeValue = typeValue.toLowerCase();

        const nameValidation = plv8.execute(`
            SELECT ${type}_name
            FROM inventory_schema.${type}_table
            WHERE LOWER(${type}_name) = $1
        `, [lowerTypeValue]);

        if (nameValidation.length > 0) {
            returnData = true;
        }
    });
    return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION event_status_update(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
  let returnData = [];
  plv8.subtransaction(function() {
    const { fieldResponse, selectedRow, teamMemberId, type,signatureUrl,eventId } = input_data;
    const currentDate = new Date(plv8.execute(`SELECT public.get_current_date()`)[0].get_current_date);
	let listOfAssets = [];

    const eventData = plv8.execute(`
        SELECT *
        FROM inventory_schema.inventory_event_table
        WHERE event_id = $1
    `,[eventId])[0];

	const combinedAssets = plv8.execute(`
	    SELECT
	        r.parent_asset_id,
	        array_agg(r.child_asset_id) as child_assets
	    FROM inventory_request_schema.inventory_request_table i
	    JOIN inventory_request_schema.inventory_relationship_table r
	    ON r.parent_asset_id = i.inventory_request_id
	    WHERE r.parent_asset_id = ANY($1)
	    GROUP BY r.parent_asset_id
	`, [selectedRow]);


        if (combinedAssets.length === 0) {
            listOfAssets = selectedRow;
        } else {
            combinedAssets.forEach(asset => {
                listOfAssets.push(asset.parent_asset_id);
                if (asset.child_assets.length > 0) {
                    asset.child_assets.forEach(childAsset => {
                        listOfAssets.push(childAsset);
                    });
                } else {
                    listOfAssets.push(asset.parent_asset_id);
                }
            });
        }

        const checkoutFrom = fieldResponse.find(f => f.name === "Check out to")?.response || null;
        const date1 = new Date(fieldResponse.find(f => f.name === "Date 1")?.response ).toIsoString()|| currentDate;
        const site = fieldResponse.find(f => f.name === "Site")?.response || null;
        const department = fieldResponse.find(f => f.name === "Department")?.response || null;
        const location = fieldResponse.find(f => f.name === "Location")?.response || null;
        const person = fieldResponse.find(f => f.name === "Assign To")?.response || null;
        const notes = fieldResponse.find(f => f.name === "Notes")?.response || null;

        let personTeamMemberId = null;
        if (person) {
            const [firstName, lastName] = person.split(' ');
            if (firstName && lastName) {
            const result = plv8.execute(`
                SELECT t.team_member_id
                FROM user_schema.user_table u
                JOIN team_schema.team_member_table t
                ON t.team_member_user_id = u.user_id
                WHERE u.user_first_name = $1 AND u.user_last_name = $2
            `, [firstName, lastName]);

            personTeamMemberId = result[0]?.team_member_id || null;
            }
        }

        let siteID = null;
        if (checkoutFrom === "Site") {
            const siteResult = plv8.execute(`
            SELECT site_id
            FROM inventory_schema.site_table
            WHERE site_name ILIKE '%' || $1 || '%'
            `, [site]);

            siteID = siteResult[0]?.site_id || null;
        }

        listOfAssets.forEach(function (requestId) {
            const currentStatusData = plv8.execute(`
                SELECT inventory_request_status
                FROM inventory_request_schema.inventory_request_table
                WHERE inventory_request_id = $1;
            `, [requestId]);

            const currentStatus = currentStatusData[0]?.inventory_request_status || null;

		   plv8.execute(`
                UPDATE inventory_request_schema.inventory_request_table
                SET
                    inventory_request_status = $1,
                    inventory_request_site = COALESCE($2, inventory_request_site),
                    inventory_request_location = COALESCE($3, inventory_request_location),
                    inventory_request_department = COALESCE($4, inventory_request_department)
                WHERE inventory_request_id = $5
                RETURNING *;
		`, [eventData.event_status, site, location, department, requestId]);

            plv8.execute(`
                UPDATE inventory_request_schema.inventory_assignee_table
                SET
                    inventory_assignee_team_member_id = $1,
                    inventory_assignee_site_id =  $2
                WHERE inventory_assignee_asset_request_id = $3;
            `, [personTeamMemberId, siteID, requestId]);

            plv8.execute(`
                INSERT INTO inventory_request_schema.inventory_history_table (
                    inventory_history_event,
                    inventory_history_changed_to,
                    inventory_history_changed_from,
                    inventory_history_request_id,
                    inventory_history_assigneed_to,
                    inventory_history_action_by
                )
                VALUES (
                    $1, $2, $3, $4, $5, $6
                );
            `, [
            eventData.event_name,
            eventData.event_status,
            currentStatus,
            requestId,
            site || person || null,
            teamMemberId
            ]);

            plv8.execute(`
                INSERT INTO inventory_request_schema.inventory_event_table (
                    inventory_event,
                    inventory_event_date_created,
                    inventory_event_notes,
                    inventory_event_request_id,
                    inventory_event_signature
                )
                VALUES (
                    $1, $2, $3, $4, $5, $6
                );
            `, [
            eventData.event_name,
            date1,
            notes,
            requestId,
            signatureUrl
            ]);
        });
  });
  return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION get_asset_history(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
 let returnData = [];
 let count = 0;
 plv8.subtransaction(function() {
    const { assetId, page = 1, limit = 13 } = input_data;
    const offset = (page - 1) * limit;

    const assetIdData = plv8.execute(`
        SELECT inventory_request_id
        FROM inventory_request_schema.inventory_request_table
        WHERE inventory_request_tag_id = '${assetId}'
    `)[0];

    const totalCountResult = plv8.execute(`
        SELECT COUNT(*) AS total_count
        FROM inventory_request_schema.inventory_history_table h
        WHERE h.inventory_history_request_id = $1
    `, [assetIdData.inventory_request_id]);

    count = parseInt(totalCountResult[0].total_count);

    const historyData = plv8.execute(`
        SELECT
            h.inventory_history_id,
            h.inventory_history_date_created,
            h.inventory_history_event,
            h.inventory_history_changed_from,
            h.inventory_history_changed_to,
            t.team_member_id,
            u.user_id,
            u.user_first_name,
            u.user_last_name
        FROM inventory_request_schema.inventory_history_table h
        INNER JOIN team_schema.team_member_table t
        ON t.team_member_id = h.inventory_history_action_by
        INNER JOIN user_schema.user_table u
        ON u.user_id = t.team_member_user_id
        WHERE h.inventory_history_request_id = $1
        ORDER BY h.inventory_history_date_created DESC
        LIMIT $2 OFFSET $3
    `, [assetIdData.inventory_request_id, limit, offset]);
    returnData = historyData;
 });
 return {
    data: returnData,
    totalCount: count
  };
$$ LANGUAGE plv8;


CREATE OR REPLACE FUNCTION update_drawer_data(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
    let returnData;
    plv8.subtransaction(function() {
        const { typeData, typeId, type } = input_data;
        let query;
        let values;

        if (typeData.typeDescription) {
            query = `
                UPDATE inventory_schema.${type}_table
                SET ${type}_name = $1, ${type}_description = COALESCE($2, ${type}_description)
                WHERE ${type}_id = $3
                RETURNING *;
            `;
            values = [typeData.typeName, typeData.typeDescription, typeId]; // 3 parameters: $1, $2, $3
        } else {
            query = `
                UPDATE inventory_schema.${type}_table
                SET ${type}_name = $1
            `;

            if (typeData.siteId) {
                // Add siteId to query
                query += `, location_site_id = $2`;
                query += ` WHERE ${type}_id = $3 RETURNING *;`;
                values = [typeData.typeName, typeData.siteId, typeId]; // 3 parameters: $1, $2, $3
            } else {
                // Query without siteId
                query += ` WHERE ${type}_id = $2 RETURNING *;`;
                values = [typeData.typeName, typeId]; // 2 parameters: $1, $2
            }
        }

        // Execute the main update query
        let result = plv8.execute(query, values);

        // Execute the separate query for sub_category_table if categoryId is present
        if (typeData.categoryId) {
            plv8.execute(`
                UPDATE inventory_schema.sub_category_table
                SET sub_category_id = $1
                WHERE sub_field_id = $2
            `, [typeData.categoryId, typeId]); // 2 parameters: $1, $2
        }

        // Set returnData to the result of the main query
        if (result.length > 0) {
            returnData = {
                type_name: result[0][`${type}_name`],
                type_description: result[0][`${type}_description`] || null
            };
        }
    });
    return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION get_item_option(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
  let returnData = [];
  plv8.subtransaction(function() {
    const { teamId } = input_data;

    const itemOption = plv8.execute(`
      SELECT item_general_name,item_id
      FROM item_schema.item_table
      WHERE item_team_id = '${teamId}'
    `);
    const existingAsset = plv8.execute(`
      SELECT inventory_request_name
      FROM inventory_request_schema.inventory_request_table
    `);
    const existingNames = existingAsset.map(asset => asset.inventory_request_name);

    itemOption.forEach(item => {
    if (!existingNames.includes(item.item_general_name)) {
        returnData.push({
          item_id:item.item_id,
          value: item.item_general_name
        });
      }
    });
  });
  return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION get_child_asset(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
    let returnData = {
        totalCount: 0,
        data: []
    };
    plv8.subtransaction(function() {
        const { assetId, limit = 10, page = 1 } = input_data;
        const offset = (page - 1) * limit;

        const assetIdData = plv8.execute(`
            SELECT inventory_request_id
            FROM inventory_request_schema.inventory_request_table
            WHERE inventory_request_tag_id = '${assetId}'
        `)[0];

        const totalCountResult = plv8.execute(`
            SELECT COUNT(*) AS total_count
            FROM inventory_request_schema.inventory_relationship_table
            WHERE parent_asset_id = $1
        `, [assetIdData.inventory_request_id]);

        returnData.totalCount = parseInt(totalCountResult[0].total_count);

        const childAssets = plv8.execute(`
            SELECT *
            FROM inventory_request_schema.inventory_relationship_table
            WHERE parent_asset_id = $1
            LIMIT $2 OFFSET $3
        `, [assetIdData.inventory_request_id, limit, offset]);

        childAssets.forEach((asset) => {
            const assetData = plv8.execute(`
                SELECT inventory_request_id,inventory_request_tag_id,inventory_request_serial_number, inventory_request_name
                FROM inventory_request_schema.inventory_request_table
                WHERE inventory_request_id = $1
            `, [asset.child_asset_id]);

            returnData.data.push({
                inventory_request_tag_id: assetData[0].inventory_request_tag_id,
                inventory_request_serial_number:assetData[0].inventory_request_serial_number,
                inventory_request_name: assetData[0].inventory_request_name
            });
        });
    });
    return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION create_asset_link(
    input_data JSON
)
RETURNS VOID
SET search_path TO ''
AS $$
 plv8.subtransaction(function() {
    const {teamMemberId, linkedAssets, assetId } = input_data;

    const assetIdData = plv8.execute(`
        SELECT inventory_request_id
        FROM inventory_request_schema.inventory_request_table
        WHERE inventory_request_tag_id = '${assetId}'
    `)[0];

    plv8.execute(`
        INSERT INTO inventory_request_schema.inventory_history_table (
            inventory_history_action_by,
            inventory_history_request_id,
            inventory_history_event
        )
        VALUES ($1, $2, $3)
    `, [teamMemberId, assetIdData.inventory_request_id, "LINK AS PARENT"]);

    linkedAssets.forEach((child) => {
        plv8.execute(`
          INSERT INTO inventory_request_schema.inventory_relationship_table (parent_asset_id, child_asset_id)
          VALUES ('${assetIdData.inventory_request_id}', '${child}')
        `);

	    plv8.execute(`
        INSERT INTO inventory_request_schema.inventory_history_table (
            inventory_history_action_by,
            inventory_history_request_id,
            inventory_history_event
        )
        VALUES ($1, $2, $3)
    `, [teamMemberId, child, "LINK AS CHILD"]);

    });
 });
$$ LANGUAGE plv8;


CREATE OR REPLACE FUNCTION get_child_asset_option(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
    let returnData = [];
    plv8.subtransaction(function() {
        const { teamId, assetId, page = 1, limit = 10 } = input_data;
        const offset = (page - 1) * limit;

        const assetIdData = plv8.execute(`
           SELECT inventory_request_id
           FROM inventory_request_schema.inventory_request_table
           WHERE inventory_request_tag_id = '${assetId}'
        `)[0];

        const itemOption = plv8.execute(`
            SELECT i.item_id, i.item_general_name, r.inventory_request_id, r.inventory_request_name
            FROM item_schema.item_table i
            INNER JOIN inventory_request_schema.inventory_request_table r
            ON i.item_general_name = r.inventory_request_name
            WHERE i.item_team_id = $1
            AND r.inventory_request_id != $2
            AND NOT EXISTS (
                SELECT 1
                FROM inventory_request_schema.inventory_relationship_table rel
                WHERE (rel.parent_asset_id = r.inventory_request_id OR rel.child_asset_id = r.inventory_request_id)
                AND (rel.parent_asset_id = $2 OR rel.child_asset_id = $2)
            )
            LIMIT $3 OFFSET $4
        `, [teamId, assetIdData.inventory_request_id, limit, offset]);

        itemOption.forEach((option) => {
            returnData.push({
                inventory_request_id: option.inventory_request_id,
                inventory_request_name: option.inventory_request_name,
                item_id: option.item_id,
                item_general_name: option.item_general_name
            });
        });
    });
    return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION get_security_group(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
    let returnData = {
        asset: {
            permissions: [],
            filter: {
                site: [],
                department: [],
                category: [],
                event: []
            }
        },
        privileges: {
            site: {},
            location: {},
            category: {},
            subCategory: {},
            department: {},
            customField: {}
        }
    };
    plv8.subtransaction(function() {
        const { groupId } = input_data;

		const permissionKeyforAsset = ["viewOnly", "addAssets", "editAssets", "deleteAssets"];
		const permissionsData = plv8.execute(`
		    SELECT p.inventory_permission_key, g.inventory_permission_value
		    FROM inventory_schema.inventory_group_permissions_table g
		    INNER JOIN inventory_schema.inventory_permissions_table p
		    ON g.inventory_permission_id = p.inventory_permission_id
		    WHERE g.inventory_group_id = $1
		    AND p.inventory_permission_key = ANY($2)
		`, [groupId, permissionKeyforAsset]);

        returnData.asset.permissions = permissionsData.map(row => ({
            key: row.inventory_permission_key,
            value: row.inventory_permission_value
        }));

        const privilegeMap = {
            site: ['view', 'add', 'edit', 'delete'],
            location: ['view', 'add', 'edit', 'delete'],
            category: ['view', 'add', 'edit', 'delete'],
            subCategory: ['view', 'add', 'edit', 'delete'],
            department: ['view', 'add', 'edit', 'delete'],
            customField: ['view', 'add', 'edit', 'delete']
        };

        Object.keys(privilegeMap).forEach((category) => {
            privilegeMap[category].forEach((action) => {
                const permissionKey = `${category}_${action}`;
                const privilegeData = plv8.execute(`
                    SELECT g.inventory_permission_value
                    FROM inventory_schema.inventory_group_permissions_table g
                    INNER JOIN inventory_schema.inventory_permissions_table p
                    ON g.inventory_permission_id = p.inventory_permission_id
                    WHERE p.inventory_permission_key = $1
                    AND g.inventory_group_id = $2
                `, [permissionKey, groupId]);

                if (privilegeData.length > 0) {
                    returnData.privileges[category][action] = privilegeData[0].inventory_permission_value;
                }
            });
        });

        const siteFilterData = plv8.execute(`
            SELECT s.site_name
            FROM inventory_schema.inventory_group_filter_table g
            INNER JOIN inventory_schema.site_table s
            ON s.site_id = g.inventory_group_filter_value_id
            WHERE g.inventory_group_filter_type = 'site' AND g.inventory_group_id = $1
        `, [groupId]);
        returnData.asset.filter.site = siteFilterData.map(row => row.site_name);

        const departmentFilterData = plv8.execute(`
            SELECT d.team_department_name
            FROM inventory_schema.inventory_group_filter_table g
            INNER JOIN team_schema.team_department_table d
            ON d.team_department_id = g.inventory_group_filter_value_id
            WHERE g.inventory_group_filter_type = 'department' AND g.inventory_group_id = $1
        `, [groupId]);
        returnData.asset.filter.department = departmentFilterData.map(row => row.team_department_name);

        const categoriesFilterData = plv8.execute(`
            SELECT c.category_name
            FROM inventory_schema.inventory_group_filter_table g
            INNER JOIN inventory_schema.category_table c
            ON c.category_id = g.inventory_group_filter_value_id
            WHERE g.inventory_group_filter_type = 'category' AND g.inventory_group_id = $1
        `, [groupId]);
        returnData.asset.filter.category = categoriesFilterData.map(row => row.category_name);

        const eventsFilterData = plv8.execute(`
            SELECT e.event_name
            FROM inventory_schema.inventory_group_filter_table g
            INNER JOIN inventory_schema.inventory_event_table e
            ON e.event_id = g.inventory_group_filter_value_id
            WHERE g.inventory_group_filter_type = 'event' AND g.inventory_group_id = $1
        `, [groupId]);
        returnData.asset.filter.event = eventsFilterData.map(row => row.event_name);
    });
    return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION update_security_group(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
    let returnData = null;
    plv8.subtransaction(function() {
        const { securityGroupsFormValues,permissionsFormValues, groupId } = input_data;

        if(securityGroupsFormValues){
            plv8.execute(`
                DELETE FROM inventory_schema.inventory_group_filter_table
                WHERE inventory_group_id = $1
            `, [groupId]);
            for (let key in securityGroupsFormValues) {
                const value = securityGroupsFormValues[key];
                if (typeof value === 'boolean') {
                    const permissionQuery = plv8.execute(`
                        SELECT inventory_permission_id
                        FROM inventory_schema.inventory_permissions_table
                        WHERE inventory_permission_key = $1
                    `, [key]);

                    if (permissionQuery.length > 0) {
                        const permissionId = permissionQuery[0].inventory_permission_id;

                        const checkExistingGroup = plv8.execute(`
                            SELECT *
                            FROM inventory_schema.inventory_group_permissions_table
                            WHERE inventory_group_id = $1
                            AND inventory_permission_id = $2
                        `, [groupId, permissionId]);

                        if (checkExistingGroup.length > 0) {
                            plv8.execute(`
                                UPDATE inventory_schema.inventory_group_permissions_table
                                SET inventory_permission_value = $1
                                WHERE inventory_group_id = $2
                                AND inventory_permission_id = $3
                            `, [value, groupId, permissionId]);
                        } else {
                            plv8.execute(`
                                INSERT INTO inventory_schema.inventory_group_permissions_table
                                (inventory_group_id, inventory_permission_id, inventory_permission_value)
                                VALUES ($1, $2, $3)
                            `, [groupId, permissionId, value]);
                        }
                    }
                }

                else if (Array.isArray(value)) {
                    value.forEach(item => {
                        let uuidQuery = null;
                        if (key === 'site') {
                            uuidQuery = plv8.execute(`
                                SELECT site_id
                                FROM inventory_schema.site_table
                                WHERE site_name = $1
                            `, [item]);
                        } else if (key === 'department') {
                            uuidQuery = plv8.execute(`
                                SELECT team_department_id
                                FROM team_schema.team_department_table
                                WHERE team_department_name = $1
                            `, [item]);
                        }else if (key === 'category'){
                            uuidQuery = plv8.execute(`
                                SELECT category_id
                                FROM inventory_schema.category_table
                                WHERE category_name = $1
                            `, [item]);
                        }else if (key === 'event'){
                            uuidQuery = plv8.execute(`
                                SELECT event_id
                                FROM inventory_schema.inventory_event_table
                                WHERE event_name = $1
                            `, [item]);
                        }

                        if (uuidQuery && uuidQuery.length > 0) {
                            const filterValueId = uuidQuery[0].site_id || uuidQuery[0].team_department_id || uuidQuery[0].category_id || uuidQuery[0].event_id;
                            const checkExistingFilter = plv8.execute(`
                                SELECT *
                                FROM inventory_schema.inventory_group_filter_table
                                WHERE inventory_group_id = $1
                                AND inventory_group_filter_type = $2
                                AND inventory_group_filter_value_id = $3
                            `, [groupId, key, filterValueId]);

                                plv8.execute(`
                                    INSERT INTO inventory_schema.inventory_group_filter_table
                                    (inventory_group_id, inventory_group_filter_type, inventory_group_filter_value_id)
                                    VALUES ($1, $2, $3)
                                `, [groupId, key, filterValueId]);

                        } else {
                            throw new Error(`No UUID found for ${item} in table ${key}`);
                        }
                    });
                }
            }
        }else if (permissionsFormValues){
          for (let category in permissionsFormValues.privileges) {
            const categoryPermissions = permissionsFormValues.privileges[category]; // Access permissions for

            for (let action in categoryPermissions) {
                const value = categoryPermissions[action];
                const permissionKey = `${category}_${action}`

                const permissionQuery = plv8.execute(`
                    SELECT inventory_permission_id
                    FROM inventory_schema.inventory_permissions_table
                    WHERE inventory_permission_key = $1
                `, [permissionKey]);

                if (permissionQuery.length > 0) {
                    const permissionId = permissionQuery[0].inventory_permission_id;
                    const checkExistingGroup = plv8.execute(`
                        SELECT *
                        FROM inventory_schema.inventory_group_permissions_table
                        WHERE inventory_group_id = $1
                        AND inventory_permission_id = $2
                    `, [groupId, permissionId]);

                    if (checkExistingGroup.length > 0) {
                        plv8.execute(`
                            UPDATE inventory_schema.inventory_group_permissions_table
                            SET inventory_permission_value = $1
                            WHERE inventory_group_id = $2
                            AND inventory_permission_id = $3
                        `, [value, groupId, permissionId]);
                    } else {
                        plv8.execute(`
                            INSERT INTO inventory_schema.inventory_group_permissions_table
                            (inventory_group_id, inventory_permission_id, inventory_permission_value)
                            VALUES ($1, $2, $3)
                        `, [groupId, permissionId, value]);
                    }
                }
            }
        }
        }
    });
    return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION create_custom_field(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
    let returnData = {};
    plv8.subtransaction(function() {
        const { fieldValue, optionsValues, categoriesValues } = input_data;

        // Insert the custom field
        const customField = plv8.execute(`
            INSERT INTO inventory_schema.field_table
            (field_id, field_name, field_is_required, field_type, field_order, field_is_custom_field, field_section_id)
            VALUES
            (${fieldValue})
            RETURNING *;
        `);

        returnData = customField[0]; // Capture the inserted field data

        // Insert into custom_field_table (if categories exist)
        if (categoriesValues && categoriesValues.length > 0) {
            plv8.execute(`
                INSERT INTO inventory_schema.custom_field_table
                (custom_field_id, category_id)
                VALUES
                ${categoriesValues};
            `);
        }

        // Insert into option_table (if options exist)
        if (optionsValues && optionsValues.length > 0) {
            plv8.execute(`
                INSERT INTO inventory_schema.option_table
                (option_value, option_order, option_field_id)
                VALUES
                ${optionsValues};
            `);
        }
    });
    return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION get_custom_field_details_on_load(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
    let returnData = [];
    plv8.subtransaction(function() {
        const { fieldId } = input_data;


        const customFields = plv8.execute(`
           SELECT *
           FROM inventory_schema.field_table
           WHERE field_id = '${fieldId}'
        `);


        customFields.forEach((field) => {
          const optionData = plv8.execute(`
             SELECT *
             FROM inventory_schema.option_table
             WHERE option_field_id = '${field.field_id}'
          `);

          const categoryData = plv8.execute(`
            SELECT *
            FROM inventory_schema.custom_field_table
            WHERE custom_field_id = '${field.field_id}'
          `);

          returnData.push({
            fieldId:field.field_id,
            fieldName: field.field_name,
            fieldType: field.field_type,
            fieldIsRequired: field.field_is_required,
            fieldOption: optionData.map((option) => option.option_value),
            fieldCategory: categoryData.map((category) => category.category_id)
          });
        });
    });
    return returnData[0];
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION update_custom_field(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
    let returnData = [];
    plv8.subtransaction(function() {
        const { fieldId, fieldValue, optionsValues, categoriesValues } = input_data;

        const customField = plv8.execute(`
            UPDATE inventory_schema.field_table
            SET
                field_name = '${fieldValue[0]}',
                field_is_required = '${fieldValue[1]}',
                field_type = '${fieldValue[2]}'
            WHERE
                field_id = '${fieldId}'
            RETURNING *;
        `);


        returnData = customField[0];

        plv8.execute(`
            DELETE FROM inventory_schema.custom_field_table
            WHERE custom_field_id = '${fieldId}'
        `)

        plv8.execute(`
            INSERT INTO inventory_schema.custom_field_table
            (custom_field_id, category_id)
            VALUES
        ${categoriesValues}
        `);

        if (optionsValues){

            plv8.execute(`
                DELETE FROM inventory_schema.option_table
                WHERE option_field_id = '${fieldId}'
            `)
            plv8.execute(`
                INSERT INTO inventory_schema.option_table
                (option_value, option_order, option_field_id)
                VALUES
            ${optionsValues}
            `);
        }
    })
    return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION get_active_group(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
    let returnData = null;
    plv8.subtransaction(function() {
        const { userId } = input_data;

        const activeGroup = plv8.execute(
            `
            SELECT tg.*
            FROM team_schema.team_member_table t
            JOIN team_schema.team_group_member_table g
            ON t.team_member_id = g.team_member_id
            JOIN team_schema.team_group_table AS tg
            ON tg.team_group_id = g.team_group_id
            WHERE t.team_member_user_id = $1
            LIMIT 1
            `,
            [userId]
        );

        if (activeGroup.length > 0) {
            returnData = activeGroup[0];
        }
    });
    return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION create_custom_event(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
    let returnData = null;

    try {
        plv8.subtransaction(function() {
            const { createEventFormvalues, teamMemberId, teamId } = input_data;
            const eventDetails = createEventFormvalues.event;
            const fieldDetails = createEventFormvalues.fields;
            const assignedToDetails = createEventFormvalues.assignedTo || {}; // Ensure this is defined

            const assignedToArray = [
                assignedToDetails.assignToPerson && "Person",
                assignedToDetails.assignToCustomer && "Customer",
                assignedToDetails.assignToLocation && "Site"
            ].filter(Boolean);

            // Sanitize event name for table creation
            const sanitizedEventName = eventDetails.eventName.toLowerCase().replace(/\s+/g, '_').replace(/[^\w]/g, '');

            const eventData = plv8.execute(`
                INSERT INTO inventory_schema.inventory_event_table (
                    event_name,
                    event_description,
                    event_color,
                    event_is_disabled,
                    event_status,
                    event_created_by,
                    event_team_id
                )
                VALUES ($1, $2, $3, $4, $5, $6, $7)
                RETURNING event_id
            `, [
                eventDetails.eventName,
                eventDetails.eventDescription,
                eventDetails.eventColor,
                eventDetails.enableEvent ? false : true,
                eventDetails.eventStatus,
                teamMemberId,
                teamId
            ])[0].event_id;

            const formData = plv8.execute(`
                INSERT INTO inventory_schema.inventory_form_table (
                    form_name,
                    form_description,
                    form_is_disabled,
                    form_team_member_id
                )
                VALUES ($1, $2, $3, $4)
                RETURNING form_id
            `, [
                eventDetails.eventName,
                eventDetails.eventDescription,
                eventDetails.enableEvent,
                teamMemberId
            ])[0].form_id;

            if (eventData && formData) {
                plv8.execute(`
                    INSERT INTO inventory_schema.event_form_connection_table (
                        event_form_event_id,
                        event_form_form_id
                    )
                    VALUES ($1, $2)
                `, [eventData, formData]);

                const sectionData = plv8.execute(`
                    INSERT INTO inventory_schema.section_table (
                        section_name,
                        section_order,
                        section_form_id
                    )
                    VALUES ($1, $2, $3)
                    RETURNING section_id
                `, [eventDetails.eventName + " Section", 1, formData])[0].section_id;

                let tableName = `event_${sanitizedEventName}_table`;
                let createTableSQL = `CREATE TABLE event_schema.${tableName} (event_${sanitizedEventName}_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), `;

                let requiredFields = fieldDetails.filter(field => field.field_is_required);

                requiredFields.forEach((field, index) => {
                    let fieldTypeSQL = '';

                    switch (field.field_type) {
                        case 'TEXT':
                        case 'TEXTAREA':
                            fieldTypeSQL = 'VARCHAR(4000) NOT NULL';
                            break;
                        case 'NUMBER':
                            fieldTypeSQL = 'INT NOT NULL';
                            break;
                        case 'CHECKBOX':
                            fieldTypeSQL = 'BOOLEAN NOT NULL';
                            break;
                        case 'DATE':
                            fieldTypeSQL = 'TIMESTAMPTZ DEFAULT NOW()';
                            break;
                        default:
                            fieldTypeSQL = 'VARCHAR(4000) NOT NULL';
                    }

                    let sanitizedFieldLabel = field.field_label.toLowerCase().replace(/\s+/g, '_').replace(/[^\w]/g, '');

                    createTableSQL += `event_${sanitizedEventName}_${sanitizedFieldLabel} ${fieldTypeSQL}${index < requiredFields.length - 1 ? ', ' : ''}`;
                });

                createTableSQL += `);`;

                // Execute table creation SQL
                plv8.execute(createTableSQL);

                // Insert fields and options into respective tables
                fieldDetails.forEach((field, index) => {
                    const fieldData = plv8.execute(`
                        INSERT INTO inventory_schema.field_table (
                            field_name,
                            field_is_required,
                            field_type,
                            field_order,
                            field_section_id
                        )
                        VALUES ($1, $2, $3, $4, $5)
                        RETURNING field_id
                    `, [
                        field.field_label,
                        field.field_is_required,
                        field.field_type,
                        index + 1,
                        sectionData
                    ])[0].field_id;

                    if (field.field_name === "Assigned To") {
                        assignedToArray.forEach((option, optionIndex) => {
                            plv8.execute(`
                                INSERT INTO inventory_schema.option_table (
                                    option_value,
                                    option_order,
                                    option_field_id
                                )
                                VALUES ($1, $2, $3)
                            `, [option, optionIndex + 1, fieldData]);
                        });
                    }
                });
            }
        });
    } catch (err) {
        plv8.elog(ERROR, `Error creating event: ${err.message}`);
        throw err;
    }
    return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION edit_custom_event_on_load(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
    let returnData = {
        event: {},
        fields: [],
        assignedTo: {
            assignToPerson: false,
            assignToCustomer: false,
            assignToSite: false
        }
    };
    plv8.subtransaction(function() {
        const { eventId } = input_data;
        const predefinedFields = [
            { field_name: "Date 1", field_type: "DATE", field_label: "Due date", field_is_required: false, field_is_included: false },
            { field_name: "Text field", field_type: "TEXT", field_label: "Text field", field_is_required: false, field_is_included: false },
            { field_name: "Currency", field_type: "NUMBER", field_label: "Amount", field_is_required: false, field_is_included: false },
            { field_name: "Boolean", field_type: "CHECKBOX", field_label: "Question", field_is_required: false, field_is_included: false },
            { field_name: "Notes", field_type: "TEXTAREA", field_label: "Notes", field_is_required: false, field_is_included: false }
        ];

        // Fetch event and connection data
        const eventConnection = plv8.execute(`
            SELECT *
            FROM inventory_schema.event_form_connection_table
            WHERE event_form_event_id = $1
        `, [eventId])[0];

        const eventData = plv8.execute(`
            SELECT *
            FROM inventory_schema.inventory_event_table
            WHERE event_id = $1
        `, [eventId])[0];

        const getEventSection = plv8.execute(`
            SELECT *
            FROM inventory_schema.section_table
            WHERE section_form_id = $1
            ORDER BY section_order ASC
        `, [eventConnection.event_form_form_id]);


        const excludedFieldNames = ["Site", "Location", "Department", "Assigned To", "Customer"];

        getEventSection.forEach((section) => {
            const fieldData = plv8.execute(`
                SELECT *
                FROM inventory_schema.field_table
                WHERE field_section_id = $1
                ORDER BY field_order ASC
            `, [section.section_id]);


            returnData.event = {
                eventName: eventData.event_name,
                eventColor: eventData.event_color,
                eventStatus: eventData.event_status,
                eventDescription: eventData.event_description,
                enableEvent: eventData.event_is_disabled ? false : true
            };

            // Filter out predefined fields that don't match existing fields
            const nonMatchingPredefinedFields = predefinedFields.filter(predefinedField =>
                !fieldData.some(field => field.field_type === predefinedField.field_type)
            );
            const nonPredefinedFields = fieldData
                .filter(field => !excludedFieldNames.includes(field.field_name) && field.field_name !== "Appointed To")
                .map(field => ({
                    field_id: field.field_id,
                    field_name: field.field_name,
                    field_type: field.field_type,
                    field_label: field.field_name || "",
                    field_is_required: field.field_is_required,
                    field_is_included: field.field_is_disabled ? false : true
                }));

            // Combine non-predefined and predefined fields
            const uniqueFields = [...nonPredefinedFields, ...nonMatchingPredefinedFields];
            returnData.fields = returnData.fields.concat(uniqueFields);

            // Handling "Appointed To" field
            const assignedToField = fieldData.find(field => field.field_name === "Appointed To");
            if (assignedToField) {
                const options = plv8.execute(`
                    SELECT option_value
                    FROM inventory_schema.option_table
                    WHERE option_field_id = $1
                `, [assignedToField.field_id]);

                returnData.assignedTo = {
                    assignToPerson: options.some(opt => opt.option_value === 'Person'),
                    assignToCustomer: options.some(opt => opt.option_value === 'Customer'),
                    assignToSite: options.some(opt => opt.option_value === 'Site')
                };
            }
        });
    });

    return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION event_status_update(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
 let returnData = [];
 plv8.subtransaction(function() {
    const { fieldResponse, selectedRow, teamMemberId, type, signatureUrl, eventId } = input_data;
    const currentDate = new Date(plv8.execute(`SELECT public.get_current_date()`)[0].get_current_date);
    let listOfAssets = [];

    const eventData = plv8.execute(`
        SELECT *
        FROM inventory_schema.inventory_event_table
        WHERE event_id = $1
    `, [eventId])[0];

    const combinedAssets = plv8.execute(`
        SELECT
            r.parent_asset_id,
            array_agg(r.child_asset_id) as child_assets
        FROM inventory_request_schema.inventory_request_table i
        JOIN inventory_request_schema.inventory_relationship_table r
        ON r.parent_asset_id = i.inventory_request_id
        WHERE r.parent_asset_id = ANY($1)
        GROUP BY r.parent_asset_id
    `, [selectedRow]);

    if (combinedAssets.length === 0) {
        listOfAssets = selectedRow;
    } else {
        combinedAssets.forEach(asset => {
            listOfAssets.push(asset.parent_asset_id);
            if (asset.child_assets.length > 0) {
                asset.child_assets.forEach(childAsset => {
                    listOfAssets.push(childAsset);
                });
            } else {
                listOfAssets.push(asset.parent_asset_id);
            }
        });
    }

    const from = fieldResponse.find(f => f.name === "Check out to" || "Assigned To" || "Appointed To")?.response || null;
    const date1 = fieldResponse.find(f => f.name === "Date 1")?.response ?
      new Date(fieldResponse.find(f => f.name === "Date 1").response).toISOString() : currentDate.toISOString();
    const site = fieldResponse.find(f => f.name === "Site")?.response || null;
    const customer = fieldResponse.find(f => f.name === "Customer")?.response || null;
    const department = fieldResponse.find(f => f.name === "Department")?.response || null;
    const location = fieldResponse.find(f => f.name === "Location")?.response || null;
    const person = fieldResponse.find(f => f.name === "Assigned To")?.response || null;

    let personTeamMemberId = null;
    if (from === "Person") {
        if(person === null) return;
        const [firstName, lastName] = person.split(' ');
        if (firstName && lastName) {
            const result = plv8.execute(`
                SELECT t.team_member_id
                FROM user_schema.user_table u
                JOIN team_schema.team_member_table t
                ON t.team_member_user_id = u.user_id
                WHERE u.user_first_name = $1 AND u.user_last_name = $2
            `, [firstName, lastName]);

            personTeamMemberId = result[0]?.team_member_id || null;
        }
    }

    let siteID = null;
    if (from === "Site") {
        const siteResult = plv8.execute(`
            SELECT site_id
            FROM inventory_schema.site_table
            WHERE site_name ILIKE '%' || $1 || '%'
        `, [site]);

        siteID = siteResult[0]?.site_id || null;
    }
    let customerID = null;
    if (from === "Customer") {
        const customerResult = plv8.execute(`
            SELECT customer_id
            FROM inventory_schema.customer_table
            WHERE customer_name ILIKE '%' || $1 || '%'
        `, [customer]);

        customerID = customerResult[0]?.customer_id || null;
    }

        listOfAssets.forEach(function(requestId) {
            const currentStatusData = plv8.execute(`
                SELECT inventory_request_status
                FROM inventory_request_schema.inventory_request_table
                WHERE inventory_request_id = $1;
            `, [requestId]);

            const currentStatus = currentStatusData[0]?.inventory_request_status || null;

            plv8.execute(`
                UPDATE inventory_request_schema.inventory_request_table
                SET
                    inventory_request_status = $1,
                    inventory_request_site = COALESCE($2, inventory_request_site),
                    inventory_request_location = $3,
                    inventory_request_department = COALESCE($4, inventory_request_department)
                WHERE inventory_request_id = $5
                RETURNING *;
            `, [eventData.event_status, site , location, department, requestId]);

            plv8.execute(`
                UPDATE inventory_request_schema.inventory_assignee_table
                SET
                    inventory_assignee_team_member_id = $1,
                    inventory_assignee_site_id = $2,
                    inventory_assignee_customer_id = $3
                    WHERE inventory_assignee_asset_request_id = $4;
            `, [eventData.event_status === "AVAILABLE" ? null : personTeamMemberId, eventData.event_status === "AVAILABLE" ? null : siteID, eventData.event_status === "AVAILABLE" ? null : customerID , requestId]);

            plv8.execute(`
                INSERT INTO inventory_request_schema.inventory_history_table (
                    inventory_history_event,
                    inventory_history_changed_to,
                    inventory_history_changed_from,
                    inventory_history_request_id,
                    inventory_history_assigneed_to,
                    inventory_history_action_by
                )
                VALUES ($1, $2, $3, $4, $5, $6);
            `, [
                eventData.event_name,
                eventData.event_status,
                currentStatus,
                requestId,
                siteID ? site :
                personTeamMemberId ? personTeamMemberId :
                person ? person :
                CustomerID ? customerID :
                null,
                teamMemberId
            ]);

            const formattedType = eventData.event_name.toLowerCase().replace(/\s+/g, '_');
            const isExistingTable = plv8.execute(`
                SELECT EXISTS (
                    SELECT 1
                    FROM information_schema.tables
                    WHERE table_schema = 'event_schema'
                    AND table_name = $1
                );
            `, ["event_" + formattedType + '_table'])[0].exists;

            if (isExistingTable) {
                const existingColumns = plv8.execute(`
                    SELECT column_name
                    FROM information_schema.columns
                    WHERE table_schema = 'event_schema'
                    AND table_name = $1;
                `, ["event_" + formattedType + '_table']).map(col => col.column_name);

                const insertColumns = [];
                const insertValues = [];

                fieldResponse.forEach((col, index) => {
                    const formattedName = col.name.toLowerCase().replace(/\s+/g, '_');

                    if (existingColumns.includes("event_" + formattedType + "_" + formattedName)) {
                        insertColumns.push("event_"+ formattedType + "_" + formattedName);
                        insertValues.push(`${insertValues.length + 1}`);
                    }
                });


                if (insertColumns.length > 0) {

                    insertColumns.push('event_' + formattedType + '_request_id');
                    insertValues.push(`${insertValues.length + 1}`);


                    const formattedValues = insertValues.map((_, index) => "$"+`${index + 1}`).join(', ');

                    const insertQuery = `
                        INSERT INTO event_schema.event_${formattedType}_table (${insertColumns.join(', ')})
                        VALUES (${formattedValues})
                    `;

                    const values = fieldResponse
                        .filter(col => existingColumns.includes("event_" + formattedType + "_" + col.name.toLowerCase().replace(/\s+/g, '_')))
                        .map(col => col.response);

                    values.push(requestId);
                    plv8.execute(insertQuery, values);
                }
           }
        });
    });
 return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION create_custom_event(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
    let returnData = null;
        plv8.subtransaction(function() {
            const { createEventFormvalues, teamMemberId, teamId } = input_data;
            const eventDetails = createEventFormvalues.event;
            const fieldDetails = createEventFormvalues.fields;
            const assignedToDetails = createEventFormvalues.assignedTo || {};

            const assignedToArray = [
                assignedToDetails.assignToPerson && "Person",
                assignedToDetails.assignToCustomer && "Customer",
                assignedToDetails.assignToSite && "Site"
            ].filter(Boolean);

            const sanitizedEventName = eventDetails.eventName.toLowerCase().replace(/\s+/g, '_').replace(/[^\w]/g, '');

            const eventData = plv8.execute(`
                INSERT INTO inventory_schema.inventory_event_table (
                    event_name,
                    event_description,
                    event_color,
                    event_is_disabled,
                    event_status,
                    event_created_by,
                    event_team_id
                )
                VALUES ($1, $2, $3, $4, $5, $6, $7)
                RETURNING event_id
            `, [
                eventDetails.eventName,
                eventDetails.eventDescription,
                eventDetails.eventColor,
                eventDetails.enableEvent ? false : true,
                eventDetails.eventStatus,
                teamMemberId,
                teamId
            ])[0].event_id;

            const formData = plv8.execute(`
                INSERT INTO inventory_schema.inventory_form_table (
                    form_name,
                    form_description,
                    form_is_disabled,
                    form_team_member_id
                )
                VALUES ($1, $2, $3, $4)
                RETURNING form_id
            `, [
                eventDetails.eventName,
                eventDetails.eventDescription,
                eventDetails.enableEvent,
                teamMemberId
            ])[0].form_id;

            if (eventData && formData) {
                plv8.execute(`
                    INSERT INTO inventory_schema.event_form_connection_table (
                        event_form_event_id,
                        event_form_form_id
                    )
                    VALUES ($1, $2)
                `, [eventData, formData]);

                const sectionData = plv8.execute(`
                    INSERT INTO inventory_schema.section_table (
                        section_name,
                        section_order,
                        section_form_id
                    )
                    VALUES ($1, $2, $3)
                    RETURNING section_id
                `, [eventDetails.eventName + " Section", 1, formData])[0].section_id;

                // Create table name
                let tableName = `event_${sanitizedEventName}_table`;
                let createTableSQL = `
                CREATE TABLE event_schema.${tableName} (
                    event_${sanitizedEventName}_id UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
                    event_${sanitizedEventName}_date_created TIMESTAMPTZ DEFAULT NOW() NOT NULL,
                    event_${sanitizedEventName}_request_id UUID NOT NULL REFERENCES inventory_request_schema.inventory_request_table(inventory_request_id) NOT NULL,
            `;
                fieldDetails.forEach((field, index) => {
                    let fieldTypeSQL = '';
                    switch (field.field_type) {
                        case 'TEXT':
                        case 'TEXTAREA':
                            fieldTypeSQL = 'VARCHAR(4000)';
                            break;
                        case 'NUMBER':
                            fieldTypeSQL = 'INT';
                            break;
                        case 'CHECKBOX':
                            fieldTypeSQL = 'BOOLEAN';
                            break;
                        case 'DATE':
                            fieldTypeSQL = 'TIMESTAMPTZ DEFAULT NOW()';
                            break;
                        default:
                            fieldTypeSQL = 'VARCHAR(4000)';
                    }

                    let sanitizedFieldLabel = field.field_label.toLowerCase().replace(/\s+/g, '_').replace(/[^\w]/g, '');

                    createTableSQL += `event_${sanitizedEventName}_${sanitizedFieldLabel} ${fieldTypeSQL}${index < fieldDetails.length - 1 ? ', ' : ''}`;
                });

                createTableSQL += `);`;
                plv8.execute(createTableSQL);
                fieldDetails.forEach((field, index) => {
                    const fieldData = plv8.execute(`
                        INSERT INTO inventory_schema.field_table (
                            field_name,
                            field_is_required,
                            field_type,
                            field_order,
                            field_section_id
                        )
                        VALUES ($1, $2, $3, $4, $5)
                        RETURNING field_id
                    `, [
                        field.field_label,
                        field.field_is_required,
                        field.field_type,
                        index + 1,
                        sectionData
                    ])[0].field_id;

                    if (field.field_name === "Appointed To") {
                        assignedToArray.forEach((option, optionIndex) => {
                            plv8.execute(`
                                INSERT INTO inventory_schema.option_table (
                                    option_value,
                                    option_order,
                                    option_field_id
                                )
                                VALUES ($1, $2, $3)
                            `, [option, optionIndex + 1, fieldData]);
                        });
                    }
                });
            }
        });
    return returnData;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION get_event_history_by_request(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
  let returnData = [];
  let allData = [];
  let count = 0;

  plv8.subtransaction(function() {
    const { assetID, page, limit, teamID } = input_data;
    const offset = (page - 1) * limit;

    const eventRequestData = plv8.execute(`
      SELECT event_name
      FROM inventory_schema.inventory_event_table
      WHERE event_team_id = $1
    `, [teamID]);

    const eventTables = eventRequestData.map(event => {
      return 'event_' + event.event_name.toLowerCase().replace(/ /g, '_') + '_table';
    });

    eventTables.forEach(eventTable => {
      const eventData = plv8.execute(`
        SELECT *
        FROM event_schema.${eventTable}
        WHERE ${eventTable.replace('_table', '')}_request_id = $1
        ORDER BY ${eventTable.replace('_table', '')}_date_created DESC
      `, [assetID]);

      eventData.forEach(row => {
        const {
          [`${eventTable.replace('_table', '')}_id`]: event_id,
          [`${eventTable.replace('_table', '')}_signature`]: event_signature,
          [`${eventTable.replace('_table', '')}_request_id`]: event_request_id,
          [`${eventTable.replace('_table', '')}_date_created`]: event_date_created,
          ...filteredRow
        } = row;

        const cleanedRow = Object.keys(filteredRow).reduce((acc, key) => {
          if (filteredRow[key] != null) {
            acc[key] = filteredRow[key];
          }
          return acc;
        }, {});

        allData.push({
          event_id,
          event_name: eventTable
            .replace('event_', '')
            .replace('_table', '')
            .replace(/_/g, ' ')
            .toUpperCase(),
          event_date_created,
          event_signature,
          ...cleanedRow
        });
      });
    });


    allData.sort((a, b) => new Date(b.event_date_created) - new Date(a.event_date_created));


    const paginatedData = allData.slice(offset, offset + limit);

    count = allData.length;

    returnData = paginatedData;
  });

  return {
    data: returnData,
    totalCount: count,
  };
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION get_asset_spreadsheet_view(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$

  let returnData = [];
  let totalCount = 0;

  plv8.subtransaction(function() {
    const {
      userId,
	  teamId,
      limit = 10,
      page = 1,
      sort,
      search,
      sites = [],
      locations,
      department = [],
      category = [],
      status,
      assignedToPerson = [],
      assignedToSite = []
    } = input_data;

    const sitesCondition = sites.length > 0 ? `AND r.inventory_request_site = ANY('{${sites.join(',')}}')` : "";
    const locationCondition = locations ? `AND r.inventory_request_location = '${locations}'` : "";
    const departmentCondition = department.length > 0 ? `AND r.inventory_request_department = ANY('{${department.join(',')}}')` : "";
    const assignedToPersonCondition = assignedToPerson.length > 0 ? `AND assignee_t.team_member_id = ANY('{${assignedToPerson.join(',')}}')` : "";
    const assignedToSiteCondition = assignedToSite.length > 0 ? `AND s.site_name= ANY('{${assignedToSite.join(',')}}')` : "";
    const categoryCondition = category.length > 0 ? `AND r.inventory_request_category = ANY('{${category.join(',')}}')` : "";
    const searchCondition = search ? `AND r.inventory_request_tag_id = '${search}'` : "";
    const statusCondition = status ? `AND r.inventory_request_status = '${status}'` : "";

    let sortDirection = sort ? 'ASC' : 'DESC';
    let sortQuery = `ORDER BY r.inventory_request_created ${sortDirection}`;
    const offset = (page - 1) * limit;

    let rawResult = plv8.execute(`
       SELECT
        r.*,
        a.inventory_assignee_asset_request_id,
        a.inventory_assignee_site_id,
        a.inventory_assignee_team_member_id,
        s.site_name,
        c.customer_name,
        t.team_member_id AS request_creator_team_member_id,
        u.user_id AS request_creator_user_id,
        u.user_first_name AS request_creator_first_name,
        u.user_last_name AS request_creator_last_name,
        u.user_avatar AS request_creator_avatar,
        assignee_t.team_member_id AS assignee_team_member_id,
        assignee_u.user_id AS assignee_user_id,
        assignee_u.user_first_name AS assignee_first_name,
        assignee_u.user_last_name AS assignee_last_name,
        e.event_color
      FROM inventory_request_schema.inventory_request_table r
      JOIN inventory_request_schema.inventory_assignee_table a
      ON a.inventory_assignee_asset_request_id = r.inventory_request_id
      LEFT JOIN inventory_schema.site_table s
      ON s.site_id = a.inventory_assignee_site_id
      LEFT JOIN inventory_schema.customer_table c
      ON c.customer_id = a.inventory_assignee_customer_id
      LEFT JOIN team_schema.team_member_table t
      ON t.team_member_id = r.inventory_request_created_by
      JOIN user_schema.user_table u
      ON u.user_id = t.team_member_user_id
      LEFT JOIN team_schema.team_member_table assignee_t
      ON assignee_t.team_member_id = a.inventory_assignee_team_member_id
      LEFT JOIN user_schema.user_table assignee_u
      ON assignee_u.user_id = assignee_t.team_member_user_id
      INNER JOIN inventory_schema.inventory_event_table e
      ON event_status = r.inventory_request_status
      WHERE r.inventory_request_form_id = '656a3009-7127-4960-9738-92afc42779a6'
      ${searchCondition}
      ${sitesCondition}
      ${locationCondition}
      ${departmentCondition}
      ${assignedToPersonCondition}
      ${assignedToSiteCondition}
      ${categoryCondition}
      ${statusCondition}
      ${sortQuery}
      LIMIT ${limit} OFFSET ${offset}
    `);

    const eventRequestData = plv8.execute(`
      SELECT event_name
      FROM inventory_schema.inventory_event_table
      WHERE event_team_id = $1
    `, [teamId]);

    const eventTables = eventRequestData.map(event => {
      return 'event_' + event.event_name.toLowerCase().replace(/ /g, '_') + '_table';
    });



    let requestMap = {};
	let listOfLatestDate = {}
    let latestNotes = null;
    let dateCreated = null;

    rawResult.forEach(row => {
      eventTables.forEach(eventTable => {
        const notesResult = plv8.execute(`
          SELECT
            ${eventTable.replace('_table', '')}_notes AS notes,
            ${eventTable.replace('_table', '')}_date_created AS date_created
          FROM event_schema.${eventTable}
          WHERE ${eventTable.replace('_table', '')}_request_id = '${row.inventory_request_id}'
          ORDER BY ${eventTable.replace('_table', '')}_date_created DESC
          LIMIT 1
        `);

       if (notesResult.length > 0 && notesResult[0].notes) {
        const currentDate = new Date(notesResult[0].date_created);
        if (!dateCreated || currentDate > dateCreated) {
        latestNotes = notesResult[0].notes;
        dateCreated = currentDate;
         }
        }
      });

      const customResponse = plv8.execute(`
          SELECT f.field_name, cr.inventory_response_value
          FROM inventory_request_schema.inventory_custom_response_table cr
          JOIN inventory_schema.field_table f
          ON f.field_id = cr.inventory_response_field_id
          WHERE cr.inventory_response_asset_request_id = '${row.inventory_request_id}' AND f.field_is_disabled = False
      `);

      if (!requestMap[row.inventory_request_id]) {
        requestMap[row.inventory_request_id] = {
          inventory_request_id: row.inventory_request_id,
          inventory_request_tag_id: row.inventory_request_tag_id,
          inventory_request_name: row.inventory_request_name,
          inventory_request_created: row.inventory_request_created,
          inventory_request_csi_code: row.inventory_request_csi_code,
          inventory_request_description: row.inventory_request_description,
          inventory_request_brand: row.inventory_request_brand,
          inventory_request_model: row.inventory_request_model,
          inventory_request_old_asset_number: row.inventory_request_old_asset_number,
          inventory_request_equipment_type: row.inventory_request_equipment_type,
          inventory_request_serial_number: row.inventory_request_serial_number,
          inventory_request_si_number: row.inventory_request_si_number,
          inventory_request_site: row.inventory_request_site,
          inventory_request_location: row.inventory_request_location,
          inventory_request_department: row.inventory_request_department,
          inventory_request_category: row.inventory_request_category,
          inventory_request_purchase_date: row.inventory_request_purchase_date,
          inventory_request_purchase_order: row.inventory_request_purchase_order,
          inventory_request_purchase_from: row.inventory_request_purchase_from,
          inventory_request_cost: row.inventory_request_cost,
          inventory_request_status: row.inventory_request_status,
          inventory_request_status_color: row.event_color,
          inventory_request_created_by: row.inventory_request_created_by,
          inventory_assignee_asset_request_id: row.inventory_assignee_asset_request_id,
          inventory_assignee_site_id: row.inventory_assignee_site_id,
          inventory_assignee_team_member_id: row.inventory_assignee_team_member_id,
          inventory_request_notes: latestNotes,
          inventory_event_date_created: dateCreated,
          site_name: row.site_name,
          customer_name:row.customer_name,
          request_creator_team_member_id: row.request_creator_team_member_id,
          request_creator_user_id: row.request_creator_user_id,
          request_creator_first_name: row.request_creator_first_name,
          request_creator_last_name: row.request_creator_last_name,
          request_creator_avatar: row.request_creator_avatar,
          assignee_team_member_id: row.assignee_team_member_id,
          assignee_user_id: row.assignee_user_id,
          assignee_first_name: row.assignee_first_name,
          assignee_last_name: row.assignee_last_name
        };
      }

      customResponse.forEach(customField => {
        requestMap[row.inventory_request_id][customField.field_name.toLowerCase()] = customField.inventory_response_value;
      });
    });

    returnData = Object.values(requestMap);

    totalCount = plv8.execute(`
      SELECT COUNT(*) AS count
      FROM inventory_request_schema.inventory_request_table r
      JOIN inventory_request_schema.inventory_assignee_table a
      ON a.inventory_assignee_asset_request_id = r.inventory_request_id
      LEFT JOIN inventory_schema.site_table s
      ON s.site_id = a.inventory_assignee_site_id
      LEFT JOIN team_schema.team_member_table t
      ON t.team_member_id = r.inventory_request_created_by
      JOIN user_schema.user_table u
      ON u.user_id = t.team_member_user_id
      LEFT JOIN team_schema.team_member_table assignee_t
      ON assignee_t.team_member_id = a.inventory_assignee_team_member_id
      LEFT JOIN user_schema.user_table assignee_u
      ON assignee_u.user_id = assignee_t.team_member_user_id
      INNER JOIN inventory_schema.inventory_event_table e
      ON event_status = r.inventory_request_status
      WHERE r.inventory_request_form_id = '656a3009-7127-4960-9738-92afc42779a6'
      ${searchCondition}
      ${sitesCondition}
      ${locationCondition}
      ${departmentCondition}
      ${assignedToPersonCondition}
      ${assignedToSiteCondition}
      ${categoryCondition}
      ${statusCondition}
    `)[0].count;
  });

  return {
    data: returnData,
    count: parseInt(totalCount)
  };
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION edit_custom_event(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
    let returnData = null;
    plv8.subtransaction(function() {
        const { editEventFormValues, teamMemberId, teamId, eventId } = input_data;
        const eventDetails = editEventFormValues.event;
        const fieldDetails = editEventFormValues.fields;
        const assignedToDetails = editEventFormValues.assignedTo || {};

        const assignedToArray = [
            assignedToDetails.assignToPerson && "Person",
            assignedToDetails.assignToCustomer && "Customer",
            assignedToDetails.assignToSite && "Site"
        ].filter(Boolean);

        const sanitizedNewEventName = eventDetails.eventName.toLowerCase().replace(/\s+/g, '_').replace(/[^\w]/g, '');

        const oldEventNameResult = plv8.execute(`
            SELECT event_name
            FROM inventory_schema.inventory_event_table
            WHERE event_id = $1
        `, [eventId]);

        let oldEventName = oldEventNameResult.length > 0
            ? oldEventNameResult[0].event_name.toLowerCase().replace(/\s+/g, '_').replace(/[^\w]/g, '')
            : null;

        let oldTableName = `event_${oldEventName}_table`;
        let newTableName = `event_${sanitizedNewEventName}_table`;

        if (oldEventName && oldEventName !== sanitizedNewEventName) {
            plv8.execute(`
                ALTER TABLE event_schema.${oldTableName}
                RENAME TO ${newTableName}
            `);
            plv8.execute(`
                ALTER TABLE event_schema.${newTableName}
                RENAME COLUMN event_${oldEventName}_id TO event_${sanitizedNewEventName}_id
            `);
            plv8.execute(`
                ALTER TABLE event_schema.${newTableName}
                RENAME COLUMN event_${oldEventName}_date_created TO event_${sanitizedNewEventName}_date_created
            `);
            plv8.execute(`
                ALTER TABLE event_schema.${newTableName}
                RENAME COLUMN event_${oldEventName}_request_id TO event_${sanitizedNewEventName}_request_id
            `);
        }

        let existingColumns = plv8.execute(`
            SELECT column_name
            FROM information_schema.columns
            WHERE table_name = $1
            AND table_schema = 'event_schema'
        `, [newTableName]).map(row => row.column_name);

        plv8.execute(`
            UPDATE inventory_schema.inventory_event_table
            SET event_name = $1, event_description = $2, event_color = $3, event_is_disabled = $4, event_status = $5
            WHERE event_id = $6
        `, [
            eventDetails.eventName,
            eventDetails.eventDescription,
            eventDetails.eventColor,
            eventDetails.enableEvent ? false : true,
            eventDetails.eventStatus,
            eventId
        ]);

        const formData = plv8.execute(`
            SELECT event_form_form_id
            FROM inventory_schema.event_form_connection_table
            WHERE event_form_event_id = $1
        `, [eventId])[0].event_form_form_id;

        plv8.execute(`
            UPDATE inventory_schema.inventory_form_table
            SET form_name = $1, form_description = $2, form_is_disabled = $3
            WHERE form_id = $4
        `, [
            eventDetails.eventName,
            eventDetails.eventDescription,
            eventDetails.enableEvent,
            formData
        ]);

        const sectionData = plv8.execute(`
            SELECT section_id
            FROM inventory_schema.section_table
            WHERE section_form_id = $1
            ORDER BY section_order ASC
        `, [formData])[0].section_id;

        plv8.execute(`
            UPDATE inventory_schema.section_table
            SET section_name = $1
            WHERE section_id = $2
        `, [
            eventDetails.eventName + " Section",
            sectionData,
        ]);

        let oldFieldData = plv8.execute(`
            SELECT field_id, field_name, field_type
            FROM inventory_schema.field_table
            WHERE field_section_id = $1
            ORDER BY field_order ASC
        `, [sectionData]);

        let oldFieldMap = {};
        oldFieldData.forEach(existingField => {
            oldFieldMap[existingField.field_id] = existingField;
        });

        const hasAssignedTo = Object.values(assignedToDetails).some(value => value === true);

        if (!hasAssignedTo) {
            plv8.execute(`
                DELETE FROM inventory_schema.option_table
                WHERE option_field_id IN (
                    SELECT field_id FROM inventory_schema.field_table
                    WHERE field_name = 'Appointed To' AND field_section_id = $1
                )
            `, [sectionData]);

            plv8.execute(`
                DELETE FROM inventory_schema.field_table
                WHERE field_name = 'Appointed To' AND field_section_id = $1
            `, [sectionData]);

            const columnToDelete = `event_${sanitizedNewEventName}_appointed_to`;
            plv8.execute(`
                ALTER TABLE event_schema.${newTableName}
                DROP COLUMN IF EXISTS ${columnToDelete}
            `);
        }

        if (!assignedToDetails.assignToPerson) {
            plv8.execute(`
                DELETE FROM inventory_schema.field_table
                WHERE field_name = 'Assigned To' AND field_section_id = $1
            `, [sectionData]);

            const columnToDelete = `event_${sanitizedNewEventName}_assigned_to`;
            plv8.execute(`
                ALTER TABLE event_schema.${newTableName}
                DROP COLUMN IF EXISTS ${columnToDelete}
            `);
        }

        if (!assignedToDetails.assignToSite) {
            const columnsToDelete = ['site', 'location', 'department'].map(fieldName =>
                `event_${sanitizedNewEventName}_${fieldName}`
            );

            columnsToDelete.forEach(column => {
                plv8.execute(`
                    ALTER TABLE event_schema.${newTableName}
                    DROP COLUMN IF EXISTS ${column}
                `);
            });

            plv8.execute(`
                DELETE FROM inventory_schema.field_table
                WHERE field_name IN ('Site', 'Location', 'Department') AND field_section_id = $1
            `, [sectionData]);
        }

        if (!assignedToDetails.assignToCustomer) {
            plv8.execute(`
                DELETE FROM inventory_schema.field_table
                WHERE field_name = 'Customer' AND field_section_id = $1
            `, [sectionData]);

            const columnToDelete = `event_${sanitizedNewEventName}_customer`;
            plv8.execute(`
                ALTER TABLE event_schema.${newTableName}
                DROP COLUMN IF EXISTS ${columnToDelete}
            `);
        }

        fieldDetails.forEach((field, index) => {
            let fieldTypeSQL = '';
            switch (field.field_type) {
                case 'TEXT':
                case 'TEXTAREA':
                    fieldTypeSQL = 'VARCHAR(4000)';
                    break;
                case 'NUMBER':
                    fieldTypeSQL = 'INT';
                    break;
                case 'CHECKBOX':
                    fieldTypeSQL = 'BOOLEAN';
                    break;
                case 'DATE':
                    fieldTypeSQL = 'TIMESTAMPTZ DEFAULT NOW()';
                    break;
                default:
                    fieldTypeSQL = 'VARCHAR(4000)';
            }

            let oldField = oldFieldMap[field.field_id];
            let oldColumnName = oldField ? `event_${oldEventName}_${oldField.field_name.toLowerCase().replace(/\s+/g, '_').replace(/[^\w]/g, '')}` : null;
            let newColumnName = `event_${sanitizedNewEventName}_${field.field_label.toLowerCase().replace(/\s+/g, '_').replace(/[^\w]/g, '')}`;

            if (oldColumnName && existingColumns.includes(oldColumnName) && !existingColumns.includes(newColumnName)) {
                plv8.execute(`
                    ALTER TABLE event_schema.${newTableName}
                    RENAME COLUMN ${oldColumnName} TO ${newColumnName}
                `);
            } else if (!existingColumns.includes(newColumnName)) {
                plv8.execute(`
                    ALTER TABLE event_schema.${newTableName}
                    ADD COLUMN ${newColumnName} ${fieldTypeSQL}
                `);
            }

            let existingField = plv8.execute(`
                SELECT field_id
                FROM inventory_schema.field_table
                WHERE field_name = $1 AND field_section_id = $2
            `, [field.field_label, sectionData]);

            if (existingField.length > 0) {
                plv8.execute(`
                    UPDATE inventory_schema.field_table
                    SET field_is_required = $1, field_name = $2, field_is_disabled = $3
                    WHERE field_id = $4
                `, [
                    field.field_is_required,
                    field.field_label,
                    field.field_is_included ? false : true,
                    existingField[0].field_id
                ]);

                field.field_id = existingField[0].field_id;
            } else {
                let newFieldId = plv8.execute(`
                    INSERT INTO inventory_schema.field_table (
                        field_name, field_is_required, field_type, field_order, field_section_id, field_is_disabled
                    ) VALUES ($1, $2, $3, $4, $5, $6)
                    RETURNING field_id
                `, [
                    field.field_label,
                    field.field_is_required,
                    field.field_type,
                    index + 1,
                    sectionData,
                    field.field_is_included ? false : true,
                ])[0].field_id;

                field.field_id = newFieldId;
            }

            if (field.field_name === "Appointed To") {
                plv8.execute(`
                    DELETE FROM inventory_schema.option_table
                    WHERE option_field_id IN (
                        SELECT field_id FROM inventory_schema.field_table
                        WHERE field_name = 'Appointed To' AND field_section_id = $1
                    )
                `, [sectionData]);

                assignedToArray.forEach((option, optionIndex) => {
                    plv8.execute(`
                        INSERT INTO inventory_schema.option_table (
                            option_value, option_order, option_field_id
                        ) VALUES ($1, $2, $3)
                    `, [option, optionIndex + 1, field.field_id]);
                });
            }
        });
    });
    return returnData;
$$ LANGUAGE plv8;


CREATE OR REPLACE FUNCTION get_asset_code_description(
    input_data JSON
)
RETURNS JSON
SET search_path TO ''
AS $$
    let returnData = null;
    plv8.subtransaction(function() {

        const { assetName, teamId } = input_data;

        const itemData = plv8.execute(`
           SELECT l.*
           FROM item_schema.item_table i
           INNER JOIN item_schema.item_level_three_description_table l
           ON l.item_level_three_description_item_id = i.item_id
           WHERE i.item_general_name = $1 AND i.item_team_id = $2 AND i.item_is_available = $3
        `, [assetName, teamId, true]); // True for item_is_available

        if (itemData.length > 0) {
            returnData = itemData[0];
        }
    })
    return returnData;
$$ LANGUAGE plv8;








npx supabase gen types typescript --project-id "weoktclknvgedvdpmkss" --schema public,history_schema,user_schema,service_schema,unit_of_measurement_schema,lookup_schema,item_schema,form_schema,request_schema,other_expenses_schema,equipment_schema,memo_schema,jira_schema,ticket_schema,team_schema,hr_schema,inventory_schema,inventory_request_schema > utils/database.ts


preparation for dynamic
