DROP SCHEMA IF EXISTS inventory_schema CASCADE;
DROP SCHEMA IF EXISTS inventory_request_schema CASCADE;
CREATE SCHEMA inventory_schema AUTHORIZATION postgres;
CREATE SCHEMA inventory_request_schema AUTHORIZATION postgres


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
   inventory_request_item_code VARCHAR(4000) NOT NULL,
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

  inventory_event_request_id UUID REFERENCES inventory_request_schema.inventory_request_table(inventory_request_id) NOT NULL
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
        WHERE
          form_id = '${formId}'
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
          AND field_is_custom_field = False AND field_is_sub_category = False AND field_is_disabled = False
          ORDER BY field_order ASC
        `
      );

      const fieldsWithOptions = fieldData.map(field => {
        const optionData = plv8.execute(`
          SELECT *
          FROM inventory_schema.option_table
          WHERE option_field_id = '${field.field_id}'
          ORDER BY option_order ASC
        `);

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

    switch(formData.form_name) {
      case "Asset Inventory":
        const departmentOptions = plv8.execute(`
          SELECT team_department_id, team_department_name
          FROM team_schema.team_department_table
        `).map((department, index) => {
          return {
            option_field_id: form.form_section[2].section_field[2].field_id,
            option_id: department.team_department_id,
            option_order: index,
            option_value: department.team_department_name,
          };
        });
         const categoryOptions = plv8.execute(`
          SELECT category_id, category_name
          FROM inventory_schema.category_table
          WHERE category_team_id = '${teamId}'
        `).map((category, index) => {
          return {
            option_field_id: form.form_section[1].section_field[0].field_id,
            option_id: category.category_id,
            option_order: index,
            option_value: category.category_name,
          };
        });
        const siteOptions = plv8.execute(`
          SELECT site_id, site_name
          FROM inventory_schema.site_table
          WHERE site_team_id = '${teamId}'
        `).map((site, index) => {
          return {
            option_field_id: form.form_section[2].section_field[0].field_id,
            option_id: site.site_id,
            option_order: index,
            option_value: site.site_name,
          };
        });
        returnData = {
          form: {
            ...form,
            form_section: [
              form.form_section[0],
              {
              ...form.form_section[1],
              section_field:[
                   {
                    ...form.form_section[1].section_field[0],
                    field_option: categoryOptions,
                  },
                ],
              },
              {
                ...form.form_section[2],
                section_field: [
                    {
                    ...form.form_section[2].section_field[0],
                    field_option: siteOptions,
                  },
                 {
                     ...form.form_section[2].section_field[1],
                 },
                  {
                    ...form.form_section[2].section_field[2],
                    field_option: departmentOptions,
                  },

                ],
              },
              form.form_section[3]
            ],
          },
          departmentOptions
        };
        break;

      case "Check In":
        const checkInSiteOptions = plv8.execute(`
          SELECT site_id, site_name
          FROM inventory_schema.site_table
        `).map((site, index) => {
          return {
            option_field_id: form.form_section[1]?.section_field[0]?.field_id,
            option_id: site.site_id,
            option_order: index,
            option_value: site.site_name,
          };
        });

        const checkInDepartmentOptions = plv8.execute(`
          SELECT team_department_id, team_department_name
          FROM team_schema.team_department_table
        `).map((department, index) => {
          return {
            option_field_id: form.form_section[1]?.section_field[3]?.field_id,
            option_id: department.team_department_id,
            option_order: index,
            option_value: department.team_department_name,
          };
        });
          returnData = {
          form: {
            ...form,
            form_section: [
              form.form_section[0],
            {
              ...form.form_section[1],
                section_field:[
                  {
                    ...form.form_section[1].section_field[0],
                   },
                   {
                    ...form.form_section[1].section_field[1],
                    field_option:checkInSiteOptions
                   },
                   {
                    ...form.form_section[1].section_field[2],
                   },
                   {
                    ...form.form_section[1].section_field[3],
                    field_option:checkInDepartmentOptions
                   },
                  {
                    ...form.form_section[2].section_field[4],
                   },
              ],
            },
            {
             ...form.form_section[2],
              section_field:[
                  {
                    ...form.form_section[2].section_field[0],
                    field_option: checkInSiteOptions,
                   },
                   {
                    ...form.form_section[2].section_field[1],
                   },
                   {
                    ...form.form_section[2].section_field[2],
                   },
                   {
                    ...form.form_section[2].section_field[3],
                    field_option:checkInDepartmentOptions
                   },
                  {
                    ...form.form_section[2].section_field[4],
                   },
              ],
            }
          ],
          },
        };
        break;

      case "Check Out":
        const checkOutSiteOptions = plv8.execute(`
          SELECT site_id, site_name
          FROM inventory_schema.site_table
        `).map((site, index) => {
          return {
            option_field_id: form.form_section[1]?.section_field[0]?.field_id,
            option_id: site.site_id,
            option_order: index,
            option_value: site.site_name,
          };
        });

        const checkOutDepartmentOptions = plv8.execute(`
          SELECT team_department_id, team_department_name
          FROM team_schema.team_department_table
        `).map((department, index) => {
          return {
            option_field_id: form.form_section[1]?.section_field[3]?.field_id,
            option_id: department.team_department_id,
            option_order: index,
            option_value: department.team_department_name,
          };
        });
          returnData = {
          form: {
            ...form,
            form_section: [
              form.form_section[0],
            {
              ...form.form_section[1],
               section_field:[
                  {
                    ...form.form_section[1].section_field[0],
                   },
                   {
                    ...form.form_section[1].section_field[1],
                   },
                   {
                    ...form.form_section[1].section_field[2],
                     field_option: checkOutSiteOptions,
                   },
                   {
                    ...form.form_section[1].section_field[3],
                   },
                  {
                    ...form.form_section[1].section_field[4],
                     field_option:checkOutDepartmentOptions
                  },
                  {
                    ...form.form_section[1].section_field[5],
                  },
              ],
            },
            {
             ...form.form_section[2],
              section_field:[
                  {
                    ...form.form_section[2].section_field[0],
                    field_option: checkOutSiteOptions,
                   },
                   {
                    ...form.form_section[2].section_field[1],
                   },
                   {
                    ...form.form_section[2].section_field[2],
                   },
                   {
                    ...form.form_section[2].section_field[3],
                    field_option:checkOutDepartmentOptions
                   },
                  {
                    ...form.form_section[2].section_field[4],
                },
              ],
            }
          ],
          },
        };
        break;
      default:
        returnData = { form };
    }
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
      item_code,
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
          inventory_request_item_code,
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
          $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20
        )
        RETURNING *
      `,
      [
        requestId,tagCount,asset_name, item_code, brand, model, serial_number, equipment_type,
        category, site, location, department, purchase_order, purchase_date,
        purchase_form, cost, si_number, formId, teamMemberId, old_asset_number
      ]
    )[0];
    plv8.execute(`
     INSERT INTO inventory_request_schema.inventory_custom_response_table
        (inventory_response_value,inventory_response_field_id,inventory_response_asset_request_id) VALUES ${responseValues}
    `);

    const request_assignee = plv8.execute(
      `
        INSERT INTO inventory_request_schema.inventory_assignee_table
        (
          inventory_assignee_asset_request_id
        )
        VALUES
        (
          $1
        )
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
        WHERE
          form_id = '${formId}'
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
          AND field_is_custom_field = False AND field_is_sub_category = False AND field_is_disabled = False
          ORDER BY field_order ASC
        `
      );

      const fieldsWithOptions = fieldData.map(field => {
        const optionData = plv8.execute(`
          SELECT *
          FROM inventory_schema.option_table
          WHERE option_field_id = '${field.field_id}'
          ORDER BY option_order ASC
        `);

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

    switch(formData.form_name) {
      case "Asset Inventory":
        const departmentOptions = plv8.execute(`
          SELECT team_department_id, team_department_name
          FROM team_schema.team_department_table
        `).map((department, index) => {
          return {
            option_field_id: form.form_section[2].section_field[2].field_id,
            option_id: department.team_department_id,
            option_order: index,
            option_value: department.team_department_name,
          };
        });
         const categoryOptions = plv8.execute(`
          SELECT category_id, category_name
          FROM inventory_schema.category_table
          WHERE category_team_id = '${teamId}'
        `).map((category, index) => {
          return {
            option_field_id: form.form_section[1].section_field[0].field_id,
            option_id: category.category_id,
            option_order: index,
            option_value: category.category_name,
          };
        });
        const siteOptions = plv8.execute(`
          SELECT site_id, site_name
          FROM inventory_schema.site_table
          WHERE site_team_id = '${teamId}'
        `).map((site, index) => {
          return {
            option_field_id: form.form_section[2].section_field[0].field_id,
            option_id: site.site_id,
            option_order: index,
            option_value: site.site_name,
          };
        });
        returnData = {
          form: {
            ...form,
            form_section: [
              form.form_section[0],
              {
              ...form.form_section[1],
              section_field:[
                   {
                    ...form.form_section[1].section_field[0],
                    field_option: categoryOptions,
                  },
                ],
              },
              {
                ...form.form_section[2],
                section_field: [
                    {
                    ...form.form_section[2].section_field[0],
                    field_option: siteOptions,
                  },
                 {
                     ...form.form_section[2].section_field[1],
                 },
                  {
                    ...form.form_section[2].section_field[2],
                    field_option: departmentOptions,
                  },

                ],
              },
              form.form_section[3]
            ],
          },
          departmentOptions
        };
        break;

      case "Check In":
        const checkInSiteOptions = plv8.execute(`
          SELECT site_id, site_name
          FROM inventory_schema.site_table
        `).map((site, index) => {
          return {
            option_field_id: form.form_section[1]?.section_field[0]?.field_id,
            option_id: site.site_id,
            option_order: index,
            option_value: site.site_name,
          };
        });

        const checkInDepartmentOptions = plv8.execute(`
          SELECT team_department_id, team_department_name
          FROM team_schema.team_department_table
        `).map((department, index) => {
          return {
            option_field_id: form.form_section[1]?.section_field[3]?.field_id,
            option_id: department.team_department_id,
            option_order: index,
            option_value: department.team_department_name,
          };
        });
          returnData = {
          form: {
            ...form,
            form_section: [
              form.form_section[0],
            {
              ...form.form_section[1],
                section_field:[
                  {
                    ...form.form_section[1].section_field[0],
                   },
                   {
                    ...form.form_section[1].section_field[1],
                    field_option:checkInSiteOptions
                   },
                   {
                    ...form.form_section[1].section_field[2],
                   },
                   {
                    ...form.form_section[1].section_field[3],
                    field_option:checkInDepartmentOptions
                   },
                  {
                    ...form.form_section[2].section_field[4],
                   },
              ],
            },
            {
             ...form.form_section[2],
              section_field:[
                  {
                    ...form.form_section[2].section_field[0],
                    field_option: checkInSiteOptions,
                   },
                   {
                    ...form.form_section[2].section_field[1],
                   },
                   {
                    ...form.form_section[2].section_field[2],
                   },
                   {
                    ...form.form_section[2].section_field[3],
                    field_option:checkInDepartmentOptions
                   },
                  {
                    ...form.form_section[2].section_field[4],
                   },
              ],
            }
          ],
          },
        };
        break;

      case "Check Out":
        const checkOutSiteOptions = plv8.execute(`
          SELECT site_id, site_name
          FROM inventory_schema.site_table
        `).map((site, index) => {
          return {
            option_field_id: form.form_section[1]?.section_field[0]?.field_id,
            option_id: site.site_id,
            option_order: index,
            option_value: site.site_name,
          };
        });

        const checkOutDepartmentOptions = plv8.execute(`
          SELECT team_department_id, team_department_name
          FROM team_schema.team_department_table
        `).map((department, index) => {
          return {
            option_field_id: form.form_section[1]?.section_field[3]?.field_id,
            option_id: department.team_department_id,
            option_order: index,
            option_value: department.team_department_name,
          };
        });
          returnData = {
          form: {
            ...form,
            form_section: [
              form.form_section[0],
            {
              ...form.form_section[1],
               section_field:[
                  {
                    ...form.form_section[1].section_field[0],
                   },
                   {
                    ...form.form_section[1].section_field[1],
                   },
                   {
                    ...form.form_section[1].section_field[2],
                     field_option: checkOutSiteOptions,
                   },
                   {
                    ...form.form_section[1].section_field[3],
                   },
                  {
                    ...form.form_section[1].section_field[4],
                     field_option:checkOutDepartmentOptions
                  },
                  {
                    ...form.form_section[1].section_field[5],
                  },
              ],
            },
            {
             ...form.form_section[2],
              section_field:[
                  {
                    ...form.form_section[2].section_field[0],
                    field_option: checkOutSiteOptions,
                   },
                   {
                    ...form.form_section[2].section_field[1],
                   },
                   {
                    ...form.form_section[2].section_field[2],
                   },
                   {
                    ...form.form_section[2].section_field[3],
                    field_option:checkOutDepartmentOptions
                   },
                  {
                    ...form.form_section[2].section_field[4],
                },
              ],
            }
          ],
          },
        };
        break;
      default:
        returnData = { form };
    }
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
      item_code,
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
          inventory_request_item_code = $2,
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
          inventory_request_old_asset_number = $18
        WHERE inventory_request_id = $19
        RETURNING *
      `,
      [
        asset_name, item_code, brand, model, serial_number, equipment_type,
        category, site, location, department, purchase_order, purchase_date,
        purchase_form, cost, si_number, formId, teamMemberId, old_asset_number, assetId
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

    let requestMap = {};

    rawResult.forEach(row => {

      const notesResult = plv8.execute(`
          SELECT *
          FROM inventory_request_schema.inventory_event_table
          WHERE inventory_event_request_id = '${row.inventory_request_id}'
          ORDER BY inventory_event_date_created DESC
          LIMIT 1
      `)[0];

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
          inventory_request_item_code: row.inventory_request_item_code,
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
          inventory_request_due_date: notesResult ? notesResult.inventory_event_due_date : null,
          inventory_request_created_by: row.inventory_request_created_by,
          inventory_assignee_asset_request_id: row.inventory_assignee_asset_request_id,
          inventory_assignee_site_id: row.inventory_assignee_site_id,
          inventory_assignee_team_member_id: row.inventory_assignee_team_member_id,
          inventory_request_notes: notesResult ? notesResult.inventory_event_notes : null,
          site_name: row.site_name,
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
    { label: "Item Code", value: "inventory_request_item_code" },
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
    { label: "Due Date", value: "inventory_request_due_date" }
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
    const { fieldResponse, selectedRow, teamMemberId, type } = input_data;
    const currentDate = new Date(plv8.execute(`SELECT public.get_current_date()`)[0].get_current_date);
	let listOfAssets = [];
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
    if (type === "Check Out") {
        const checkoutFrom = fieldResponse.find(f => f.name === "Check out to")?.response || null;
        const site = fieldResponse.find(f => f.name === "Site")?.response || null;
        const department = fieldResponse.find(f => f.name === "Department")?.response || null;
        const location = fieldResponse.find(f => f.name === "Location")?.response || null;
        const person = fieldResponse.find(f => f.name === "Assign To")?.response || null;
        const dueDate = fieldResponse.find(f => f.name === "Due Date")?.response
        ? new Date(fieldResponse.find(f => f.name === "Due Date")?.response).toISOString()
        : null;
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
		`, ["CHECKED OUT", site, location, department, requestId]);

            plv8.execute(`
                UPDATE inventory_request_schema.inventory_assignee_table
                SET
                    inventory_assignee_team_member_id =COALESCE($1, inventory_assignee_site_id),
                    inventory_assignee_site_id =  COALESCE($2, inventory_assignee_site_id)
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
            type,
            "CHECKED OUT",
            currentStatus,
            requestId,
            site || person,
            teamMemberId
            ]);

            plv8.execute(`
                INSERT INTO inventory_request_schema.inventory_event_table (
                    inventory_event,
                    inventory_event_check_out_date,
                    inventory_event_due_date,
                    inventory_event_notes,
                    inventory_event_request_id
                )
                VALUES (
                    $1, $2, $3, $4, $5
                );
            `, [
            type.toUppercase(),
            currentDate,
            dueDate,
            notes,
            requestId,
            ]);
        });
    }else if (type === "Check In"){
      const site = fieldResponse.find(f => f.name === "Site")?.response || null;
      const department = fieldResponse.find(f => f.name === "Department")?.response || null;
      const location = fieldResponse.find(f => f.name === "Location")?.response || null;
      const returnDate = fieldResponse.find(f => f.name === "Return Date")?.response
        ? new Date(fieldResponse.find(f => f.name === "Return Date")?.response).toISOString()
        : null;
      const notes = fieldResponse.find(f => f.name === "Notes")?.response || null;



      listOfAssets.forEach(function(requestId) {
        const currentStatusData = plv8.execute(`
          SELECT inventory_request_status
          FROM inventory_request_schema.inventory_request_table
          WHERE inventory_request_id = $1;
        `, [requestId]);

        const currentStatus = currentStatusData[0].inventory_request_status;
        const requestData = plv8.execute(`
          UPDATE inventory_request_schema.inventory_request_table
          SET
            inventory_request_status = $1,
            inventory_request_site = COALESCE($2, inventory_request_site),
		    inventory_request_location = COALESCE($3, inventory_request_location),
		    inventory_request_department = COALESCE($4, inventory_request_department)
          WHERE inventory_request_id = $5
          RETURNING *;
        `, ["AVAILABLE", site, department,location, requestId]);

        const assigneeData = plv8.execute(`
          UPDATE inventory_request_schema.inventory_assignee_table
          SET
            inventory_assignee_team_member_id = $1,
            inventory_assignee_site_id = $2
          WHERE inventory_assignee_asset_request_id = $3
        `, [null, null, requestId]);

        plv8.execute(`
          INSERT INTO inventory_request_schema.inventory_history_table (
            inventory_history_event,
            inventory_history_changed_to,
            inventory_history_changed_from,
            inventory_history_request_id,
            inventory_history_returned_to,
            inventory_history_action_by
          )
          VALUES (
            $1,
            $2,
            $3,
            $4,
            $5,
            $6
          );
        `, [
          type,
          "AVAILABLE",
          currentStatus,
          requestId,
          site,
          teamMemberId
        ]);

         plv8.execute(`
                INSERT INTO inventory_request_schema.inventory_event_table (
                    inventory_event,
                    inventory_event_return_date,
                    inventory_event_notes,
                    inventory_event_request_id
                )
                VALUES (
                    $1, $2, $3, $4
                );
            `, [
            type,
            currentDate,
            notes,
            requestId,
            ]);
      })
    }
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
            // Main update query when description is present
            query = `
                UPDATE inventory_schema.${type}_table
                SET ${type}_name = $1, ${type}_description = COALESCE($2, ${type}_description)
                WHERE ${type}_id = $3
                RETURNING *;
            `;
            values = [typeData.typeName, typeData.typeDescription, typeId]; // 3 parameters: $1, $2, $3
        } else {
            // Main update query without description
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
            [userId]  // Using parameterized query to avoid SQL injection
        );

        if (activeGroup.length > 0) {
            returnData = activeGroup[0];
        }
    });
    return returnData;
$$ LANGUAGE plv8;



modalFormOnload missing

npx supabase gen types typescript --project-id "weoktclknvgedvdpmkss" --schema public,history_schema,user_schema,service_schema,unit_of_measurement_schema,lookup_schema,item_schema,form_schema,request_schema,other_expenses_schema,equipment_schema,memo_schema,jira_schema,ticket_schema,team_schema,hr_schema,inventory_schema,inventory_request_schema > utils/database.ts
