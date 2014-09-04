<h1><i class="fa fa-search"></i> Apache Solr</h1>

<div class="row">
	<div class="col-sm-8">
		<div class="alert alert-info">
			<p>
				<strong><i class="fa fa-warning"></i> Please Note</strong>
			</p>
			<p>
				By default, Solr is not secured against outside access. For the safety and integrity of
				your data, it is recommended that you maintain a firewall to close off public access
				to the Tomcat/Jetty server that is serving Solr. (On Ubuntu, the <code>ufw</code> utility
				works well). You can also elect to limit access to requests from the NodeBB server only.
			</p>
			<p>
				For more information: <a href="https://wiki.apache.org/solr/SolrSecurity">https://wiki.apache.org/solr/SolrSecurity</a>
			</p>
		</div>

		<h3>Client Configuration</h2>
		<form role="form" class="solr-settings">
			<div class="form-group">
				<label for="host">Host</label>
				<input class="form-control" type="text" name="host" id="host" placeholder="Default: 127.0.0.1" />
			</div>
			<div class="form-group">
				<label for="port">Port</label>
				<input class="form-control" type="text" name="port" id="port" placeholder="Default: 8983" />
			</div>

			<h4>Authentication</h3>
			<p class="help-block">
				If your Tomcat/Jetty server is configured with HTTP Basic Authentication, enter its credentials here.
				Leave it blank otherwise.
			</p>
			<div class="form-group col-sm-6">
				<label for="username">Username</label>
				<input class="form-control" type="text" name="username" id="username" />
			</div>
			<div class="form-group col-sm-6">
				<label for="password">Password</label>
				<input class="form-control" type="password" name="password" id="password" />
			</div>

			<h4>Custom Fields</h4>
			<div class="row">
				<div class="form-group col-xs-6">
					<label for="titleField">Title Field</label>
					<input class="form-control" type="text" placeholder="Default: title_t" id="titleField" name="titleField" />
				</div>
				<div class="form-group col-xs-6">
					<label for="contentField">Content Field</label>
					<input class="form-control" type="text" placeholder="Default: description_t" id="contentField" name="contentField" />
				</div>
				<p class="help-block col-xs-12">
					If you have specified your own field schema in your Solr <code>schema.xml</code>
					file, you an specify the custom fields here.
				</p>
			</div>

			<button id="save" type="button" class="btn btn-primary btn-block">Save</button>
		</form>

		<h2>Advanced Options</h2>
		<button class="btn btn-success" data-action="rebuild">Rebuild Search Index</button>
		<p class="help-block">
			This option reads every topic and post saved in the database and adds it to the search index.
			Any topics already indexed will have their contents replaced, so there is no need to flush
			the index prior to re-indexing.
		</p>
		<button class="btn btn-danger" data-action="flush">Flush Search Index</button>
		<p class="help-block">
			Flushing the search index will remove all references to searchable assets
			in the Solr backend, and your users will no longer be able to search for
			topics. New topics and posts made after a flush will still be indexed.
		</p>
	</div>
	<div class="col-sm-4">
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title">
					<!-- IF ping -->
					<i class="fa fa-circle text-success"></i> Connected
					<!-- ELSE -->
					<i class="fa fa-circle text-danger"></i> Not Connected
					<!-- ENDIF ping -->
				</h3>
			</div>
			<div class="panel-body">
				<!-- IF ping -->
				<p>
					NodeBB has successfully connected to the Solr search engine.
				</p>
				<!-- ELSE -->
				<p>
					NodeBB could not establish a connection to the Solr search engine.
				</p>
				<p>
					Please ensure your configuration settings are correct.
				</p>
				<!-- ENDIF ping -->

				<!-- IF enabled -->
				<button class="btn btn-success btn-block" data-action="toggle" data-enabled="1"><i class="fa fa-fw fa-play"></i> &nbsp; Indexing Enabled</button>
				<p class="help-block">
					Topics and Posts will be automatically added to the search index.
				</p>
				<!-- ELSE -->
				<button class="btn btn-warning btn-block" data-action="toggle" data-enabled="0"><i class="fa fa-fw fa-pause"></i> &nbsp; Indexing Disabled</button>
				<p class="help-block">
					Indexing is currently paused, Topics and Posts will not be automatically added to the search index.
				</p>
				<!-- ENDIF enabled -->
			</div>
		</div>
		<div class="panel panel-default">
			<div class="panel-heading">
				<h3 class="panel-title">
					Statistics
				</h3>
			</div>
			<div class="panel-body">
				<!-- IF stats -->
				<ul>
					<li>Total items indexed: {stats.total}</li>
					<li>Topics indexed: {stats.topics}</li>
				</ul>
				<!-- ELSE -->
				<p>
					There are no statistics to report.
				</p>
				<!-- ENDIF stats -->
			</div>
		</div>
	</div>
</div>
<script>
	$(document).ready(function() {
		var	csrf = '{csrf}' || $('#csrf_token').val();

		// Flush event
		$('button[data-action="flush"]').on('click', function() {
			bootbox.confirm('Are you sure you wish to empty the Solr search index?', function(confirm) {
				if (confirm) {
					$.ajax({
						url: config.relative_path + '/admin/plugins/solr/flush',
						type: 'DELETE',
						data: {
							_csrf: csrf
						}
					}).success(function() {
						ajaxify.refresh();

						app.alert({
							type: 'success',
							alert_id: 'solr-flushed',
							title: 'Search index flushed',
							timeout: 2500
						});
					});
				}
			});
		});

		// Toggle event
		$('button[data-action="toggle"]').on('click', function() {
			$.ajax({
				url: config.relative_path + '/admin/plugins/solr/toggle',
				type: 'POST',
				data: {
					_csrf: csrf,
					state: parseInt($('button[data-action="toggle"]').attr('data-enabled'), 10) ^ 1
				}
			}).success(ajaxify.refresh);
		});

		// Index All event
		$('button[data-action="rebuild"]').on('click', function() {
			bootbox.confirm('Rebuild search index?', function(confirm) {
				if (confirm) {
					app.alert({
						type: 'info',
						alert_id: 'solr-rebuilt',
						title: '<i class="fa fa-refresh fa-spin"></i> Rebuilding search index...'
					});

					$.ajax({
						url: config.relative_path + '/admin/plugins/solr/rebuild',
						type: 'POST',
						data: {
							_csrf: csrf
						}
					}).success(function() {
						ajaxify.refresh();

						app.alert({
							type: 'success',
							alert_id: 'solr-rebuilt',
							title: 'Search index rebuilt',
							timeout: 2500
						});
					});
				}
			});
		});

		// Settings form event
		require(['settings'], function(Settings) {
			Settings.load('solr', $('.solr-settings'));

			$('#save').on('click', function() {
				Settings.save('solr', $('.solr-settings'), function() {
					app.alert({
						type: 'success',
						alert_id: 'solr-saved',
						title: 'Settings Saved',
						message: 'Click here to reload NodeBB',
						timeout: 2500,
						clickfn: function() {
							socket.emit('admin.reload');
						}
					});
				});
			});
		});
	});
</script>