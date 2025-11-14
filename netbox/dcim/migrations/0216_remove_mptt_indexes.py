# Generated manually to remove legacy MPTT indexes

from django.db import migrations


def remove_indexes_if_exist(apps, schema_editor):
    """Remove indexes only if they exist"""
    db_alias = schema_editor.connection.alias

    # Check and remove inventoryitem index
    with schema_editor.connection.cursor() as cursor:
        cursor.execute("""
            SELECT indexname FROM pg_indexes
            WHERE indexname = 'dcim_inventoryitem_tree_id975c'
        """)
        if cursor.fetchone():
            cursor.execute("DROP INDEX IF EXISTS dcim_inventoryitem_tree_id975c")

    # Check and remove inventoryitemtemplate index
    with schema_editor.connection.cursor() as cursor:
        cursor.execute("""
            SELECT indexname FROM pg_indexes
            WHERE indexname = 'dcim_inventoryitemtemplatedee0'
        """)
        if cursor.fetchone():
            cursor.execute("DROP INDEX IF EXISTS dcim_inventoryitemtemplatedee0")


class Migration(migrations.Migration):

    dependencies = [
        ('dcim', '0215_rackreservation_status'),
    ]

    operations = [
        migrations.RunPython(
            remove_indexes_if_exist,
            reverse_code=migrations.RunPython.noop
        ),
    ]
