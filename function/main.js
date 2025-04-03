const platformClient = require("purecloud-platform-client-v2");

function setLogger(client) {
  client.config.logger.log_level =
    client.config.logger.logLevelEnum.level.LTrace;
  client.config.logger.log_format =
    client.config.logger.logFormatEnum.formats.LTrace;
  client.config.logger.log_request_body = true;
  client.config.logger.log_response_body = true;
  client.config.logger.log_to_console = false;
  client.config.logger.log_file_path = "./log/javascriptsdk.log";

  client.config.logger.setLogger(); // To apply above changes
}

function getYesterdayInterval() {
  const now = new Date();

  // Get yesterday's date
  const yesterday = new Date();
  yesterday.setUTCDate(now.getUTCDate() - 1);
  yesterday.setUTCHours(0, 0, 0, 0);

  // Get the end of yesterday (23:59:59.999 UTC)
  const endOfYesterday = new Date(yesterday);
  endOfYesterday.setUTCHours(23, 59, 59, 999);

  // Format as ISO 8601
  const startISO = yesterday.toISOString();
  const endISO = endOfYesterday.toISOString();

  return `${startISO}/${endISO}`;
}

function getInterval(event) {
  let interval = event.interval;
  let maxDuration = event.maxDuration;

  if (!maxDuration) {
    maxDuration = 1000;
  }

  if (!interval) {
    interval = getYesterdayInterval();
  }

  return [interval, maxDuration];
}

function getContextParams(context) {
  const clientContext = context.clientContext;
  const clientId = clientContext.gc_client_id;
  const clientSecret = clientContext.gc_client_secret;
  const region = clientContext.gc_aws_region;

  if (!clientId || !clientSecret || !region) {
    throw new Error("input mising");
  }

  return [clientId, clientSecret, region];
}

function buildShortConversationBody(interval, maxDuration) {
  return {
    conversationFilters: [
      {
        type: "and",
        predicates: [
          {
            metric: "tConversationDuration",
            operator: "exists",
          },
          {
            metric: "tConversationDuration",
            range: {
              gte: 0,
              lte: maxDuration,
            },
          },
        ],
      },
    ],
    interval: interval,
  };
}

async function getShortConversations(interval, maxDuration) {
  const body = buildShortConversationBody(interval, maxDuration);
  const conversations = await getConversations(
    body
  );
  const clearedConversations = clearConversations(conversations);
  return clearedConversations;
}

function buildActionBody(interval) {
  return {
    filter: {
      type: "and",
      clauses: [
        {
          type: "or",
          predicates: [
            {
              dimension: "actionId",
              operator: "exists",
            },
          ],
        },
      ],
    },
    metrics: ["tTotalExecution"],
    groupBy: ["actionId", "errorType", "responseStatus"],
    interval: interval,
  };
}

function clearAggregates(datas) {
  const clearedAggregates = [];

  if (!datas) {
    return [];
  }

  datas.results.forEach((aggregate) => {
    const clearedAggregate = clearAggregate(aggregate);
    if (clearedAggregate) {
        clearedAggregates.push(clearedAggregate);
    }
  });

  return clearedAggregates;
}

function clearAggregate(aggregate) {
  const errorType = aggregate.group.errorType;
  if (errorType == "NONE") {
    return;
  }

  const responeStatus = aggregate.group.responseStatus;
  const actionId = aggregate.group.actionId;
  const count = aggregate.data[0].metrics[0].stats.count;
  return {
    actionId: actionId,
    responseStatus: responeStatus,
    errorType: errorType,
    count: count,
  };
}

async function getAggregates(body) {
  const analyticsApi = new platformClient.AnalyticsApi();
  return await analyticsApi.postAnalyticsActionsAggregatesQuery(body);
}

async function getDataActions(interval) {
  const body = buildActionBody(interval);
  const aggregates = await getAggregates(body);

  return clearAggregates(aggregates);
}

function buildFlowErrorBody(interval) {
  return {
    segmentFilters: [
      {
        type: "or",
        predicates: [
          {
            type: "dimension",
            dimension: "exitReason",
            value: "FLOW_ERROR_DISCONNECT",
          }
        ]
      }
    ],
    interval: interval,
  };
}

async function getConversations(body) {
  const conversationApi = new platformClient.ConversationsApi();
  return await conversationApi.postAnalyticsConversationsDetailsQuery(body);
}

function clearConversations(datas) {
  const clearedConversations = [];

  if (!datas) {
    return {};
  }

  datas.conversations.forEach((conversation) => {
    const clearedConversation = conversation.conversationId;
    if (clearedConversation) {
      clearedConversations.push(clearedConversation);
    }
  });

  return {
    conversations: clearedConversations,
    total: clearedConversations.length
  };
}

async function getFlowsErrors(interval) {
  const body = buildFlowErrorBody(interval);
  const conversations = await getConversations(body);

  return clearConversations(conversations);
}

exports.handler = async (event, context) => {
  try {
    const [interval, maxDuration] = getInterval(event);
    const [clientId, clientSecret, region] = getContextParams(context);

    const client = platformClient.ApiClient.instance;
    setLogger(client);
    client.setEnvironment(platformClient.PureCloudRegionHosts[region]);
    await client.loginClientCredentialsGrant(clientId, clientSecret);

    const shortConversations = await getShortConversations(interval, maxDuration);
    const flowErrors = await getFlowsErrors(interval);
    const dataActions = await getDataActions(interval);

    return {
      shortConversations: shortConversations,
      flowErrors: flowErrors,
      dataActionErrors: dataActions
    }

  } catch (error) {
    console.log(error);
    return;
  }
};

if (require.main === module) {
  const customContext = {
    clientContext: {
      gc_client_id: "",
      gc_client_secret: "",
      gc_aws_region: "eu_west_1",
    },
  };
  const customEvent = {
    interval: "2025-01-31T23:00:00.000Z/2025-02-28T23:00:00.000Z",
    maxDuration: "",
  };
  handler(customEvent, customContext)
    .then((data) => console.log(data))
    .catch((err) => console.error(err));
}
