# Generated manually to remove legacy MPTT indexes

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('dcim', '0215_rackreservation_status'),
    ]

    operations = [
        migrations.RemoveIndex(
            model_name='inventoryitem',
            name='dcim_inventoryitem_tree_id975c',
        ),
        migrations.RemoveIndex(
            model_name='inventoryitemtemplate',
            name='dcim_inventoryitemtemplatedee0',
        ),
    ]
